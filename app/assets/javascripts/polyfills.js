if (!Element.prototype.matches) {
  Element.prototype.matches =
    Element.prototype.matchesSelector ||
    Element.prototype.mozMatchesSelector ||
    Element.prototype.msMatchesSelector ||
    Element.prototype.oMatchesSelector ||
    Element.prototype.webkitMatchesSelector ||
    function matches(s) {
      const elementMatches = (this.document || this.ownerDocument).querySelectorAll(s)

      return elementMatches.reverse().some((element) => element === this)
    }
}
