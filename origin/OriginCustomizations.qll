module AWS {
  private import python
  private import semmle.python.dataflow.new.RemoteFlowSources
  private import semmle.python.ApiGraphs
  private import semmle.python.security.dataflow.ReflectedXSSCustomizations
  private import semmle.python.security.dataflow.ReflectedXssQuery as XssQuery

  module Response {
    API::Node classRef() {
      result =
        API::moduleImport("aws_lambda_powertools")
            .getMember("event_handler")
            .getMember("api_gateway")
            .getMember("Response")
            .getASubclass*()
    }

    API::CallNode instance() { result = classRef().getACall() }
  }

  module Router {
    API::Node classRef() {
      result =
        API::moduleImport("aws_lambda_powertools")
            .getMember("event_handler")
            .getMember("api_gateway")
            .getMember([
                "ApiGatewayResolver", "APIGatewayRestResolver", "APIGatewayHttpResolver",
                "BaseRouter", "ALBResolver"
              ])
            .getASubclass*()
    }

    API::Node instance() { result = classRef().getReturn() }

    class RouteCall extends DataFlow::CallCfgNode {
      string httpVerb;

      RouteCall() {
        httpVerb = ["get", "put", "post", "delete", "patch"] and
        (
          this = instance().getMember(httpVerb).getACall()
          or
          exists(API::Node routeCall |
            routeCall = instance().getMember("route") and
            routeCall
                .getKeywordParameter("method")
                .getARhs()
                .asExpr()
                .(List)
                .getASubExpression()
                .(StrConst)
                .getText()
                .toLowerCase() = httpVerb and
            this = routeCall.getACall()
          )
        )
      }

      Function getARequestHandler() { result.getADecorator().getAFlowNode() = node }
    }

    class CurrentEventSource extends RemoteFlowSource::Range {
      CurrentEventSource() {
        exists(API::Node an |
          an = instance().getMember("current_event") and
          this = [an, an.getAMember()].getInducingNode()
        )
      }

      override string getSourceType() { result = "AwsCurrentEventSource" }
    }
  }

  class AwsRemoteData extends RemoteFlowSource::Range {
    AwsRemoteData() {
      exists(Router::RouteCall rc | rc.getARequestHandler().getAnArg() = this.asExpr())
    }

    override string getSourceType() { result = "AwsSource" }
  }

  class AwsSink extends ReflectedXss::Sink {
    AwsSink() {
      exists(Router::RouteCall rc |
        rc.getARequestHandler().getAReturnValueFlowNode() = this.asCfgNode()
      )
    }
  }

  class ReflectedXssConf extends XssQuery::Configuration {
    override predicate isAdditionalTaintStep(DataFlow::Node n1, DataFlow::Node n2) {
      exists(API::CallNode responseCtorCall |
        responseCtorCall = AWS::Response::instance() and
        responseCtorCall.getParameter(2).getARhs() = n1 and
        responseCtorCall = n2
      )
    }
  }
}
