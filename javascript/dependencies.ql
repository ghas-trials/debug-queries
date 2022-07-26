/**
 * @name List of external dependencies
 * @description Print a list of external dependencies with usage counts.
 * @id js/dependencies-debug
 * @kind diagnostic
 */

import semmle.javascript.dependencies.Dependencies

bindingset[s, times]
string repeat(string s, int times) {
  if times = 0 then result = "" else
  result = strictconcat(int i | i = [0 .. times - 1] | s)
}

bindingset[s, padlen, char]
string pad(string s, int padlen, string char) { result = repeat(char, padlen - s.length()) + s }

predicate externalDependencies(Dependency dep, string name, int ndeps) {
  exists(string id, string v | dep.info(id, v) | name = id + "-" + v) and
  ndeps = count(Locatable use | use = dep.getAUse(_))
}

from string name, int ndeps, int padlen, string output
where
  externalDependencies(_, name, ndeps) and
  padlen = max(int n | externalDependencies(_, _, n) | n).toString().length() and
  output = pad(ndeps.toString(), padlen, "0") + "  " + name
select output, 0 order by output desc
