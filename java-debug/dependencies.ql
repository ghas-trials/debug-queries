/**
 * @id java/dependencies-debug
 * @kind diagnostic
 */

import java
import semmle.code.java.DependencyCounts

predicate jarDependencyCount(int total, string entity) {
  exists(JarFile targetJar, string jarStem |
    jarStem = targetJar.getStem() and
    jarStem != "rt"
  |
    total =
      sum(RefType r, RefType dep, int num |
        r.fromSource() and
        not dep.fromSource() and
        dep.getFile().getParentContainer*() = targetJar and
        numDepends(r, dep, num)
      |
        num
      ) and
    entity = jarStem
  )
}

bindingset[s, times]
string repeat(string s, int times) {
  if times = 0 then result = "" else
  result = strictconcat(int i | i = [0 .. times - 1] | s)
}

bindingset[s, padlen, char]
string pad(string s, int padlen, string char) { result = repeat(char, padlen - s.length()) + s }

from string name, int ndeps, int padlen, string output
where
  jarDependencyCount(ndeps, name) and
  padlen = max(int n | jarDependencyCount(n, _) | n).toString().length() and
  output = pad(ndeps.toString(), padlen, "0") + "  " + name
select output, 0 order by output desc
