from aws_lambda_powertools import Tracer
from aws_lambda_powertools.event_handler.api_gateway import ApiGatewayResolver, APIGatewayRestResolver, APIGatewayHttpResolver, BaseRouter, Response
import os.path
from os.path import join, normpath


tracer = Tracer()
app = ApiGatewayResolver()
app = APIGatewayRestResolver()
app = APIGatewayHttpResolver()


class SlackManager:
  def send_slack_notification_success(self, msg, event_source):
    pass

slack_mgr = SlackManager()


class ValidationManager:
  def validate_roles_update_req(self, req_obj):
    return True


class UserRoleUpdateRequest:
  def __init__(self, user_id, event_body):
    self.user_id = user_id
    self.event_body = event_body
    self.event_source = None


class SupportSiteManager:
  def start_webdriver(self):
    pass

  def modify_user_roles(self, req_obj):
    return req_obj.event_body + req_obj.user_id


@app.put("/api/v1/user/<user_id>/roles")
@tracer.capture_method
def user_roles_update(user_id):
    """ Update user roles """
    support_site_mgr, _, validation_mgr = setup_per_req()
    event_body = app.current_event.json_body
    req_obj = UserRoleUpdateRequest(user_id, event_body)
    validation_mgr.validate_roles_update_req(req_obj)
    support_site_mgr.start_webdriver()
    msg = support_site_mgr.modify_user_roles(req_obj)
    # TODO: Would be nice to use user.email in msg below. Needs to come from DB though
    slack_mgr.send_slack_notification_success(f"*{msg}*", req_obj.event_source)
    body = {"status": f"OK: {msg}"}
    return json_response(200, body)


@app.put("/api/v1/user2/<user_id>/roles")
@tracer.capture_method
def user_roles_update2(user_id):
    return user_id


@app.put("/api/v1/user3/<user_id>/roles")
@tracer.capture_method
def user_roles_update3(user_id):
    return json_response(200, user_id)


@app.route("/hello", method=["PUT", "POST"])
@tracer.capture_method
def user_roles_update4(user_id):
    return user_id


@app.put("/api/v1/user5/<user_id>/roles")
@tracer.capture_method
def user_roles_update5(user_id):
    return {"message": f"hello {user_id}"}


@app.put("/api/v1/user6/<user_id>/roles")
@tracer.capture_method
def user_roles_update6(user_id):
    return {"message": user_id}


@app.put("/api/v1/user7/<user_id>/roles")
@tracer.capture_method
def user_roles_update7(user_id):
    p = app.current_event.path
    return {"message": p}


@app.put("/api/v1/user8/<user_id>/roles")
@tracer.capture_method
def user_roles_update8(user_id):
    e = app.current_event
    return {"message": e}


@app.put("/api/v1/user9/<user_id>/roles")
@tracer.capture_method
def user_roles_update9(user_id):
    shn = app.current_event.headers['someheadername']
    return {"message": shn}


def json_response(code, body):
  return Response(code, "application/json", body)


def setup_per_req():
  return SupportSiteManager(), None, ValidationManager()


@app.put("/api/v1/user4/<user_id>/pathinject")
def path_injection(user_id):
    filename = user_id + ".txt"
    npath = normpath(join('/myapp', filename))
    f = open(npath)
