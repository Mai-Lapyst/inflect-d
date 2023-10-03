module inflect.en;

import inflect;
import std.regex;
import std.string : endsWith;

struct Replacement {
    Regex!char regex;
    string replacement;
}

const Replacement[] plurals = [
    { regex("(c)hildren$", "i"), "$1children" },
    { regex("(c)child$", "i"), "$1children" },
    { regex("(m)men$", "i"), "$1men" },
    { regex("(m)man$", "i"), "$1men" },
    { regex("(p)eople$", "i"), "$1eople" },
    { regex("(p)erson$", "i"), "$1eople" },
    { regex("(quiz)$", "i"), "$1zes" },
    { regex("(m|l)(ouse|ice)$", "i"), "$1ice" },
    { regex("(cod)ex$", "i"), "$1ices" },
    { regex("(matr|vert|ind)(?:ix|ex)$", "i"), "$1ices" },
    { regex("(x|ch|ss|sh)$", "i"), "$1es" },
    { regex("sis$", "i"), "ses" },
    { regex("(buffal|tomat)o$", "i"), "$1oes" },
    { regex("(bu)s$", "i"), "$1ses" },
    { regex("(alias|status)$", "i"), "$1es" },
    { regex("(octop|vir)(us|i)$", "i"), "$1i" },
    { regex("^(ax|test)es$", "i"), "$1es" },
    { regex("s$"), "s" },
    { regex("$"), "s" }
];

const string[] uncountables = [
    "equipment", "information", "rice", "money", "species", "series", "fish", "sheep", "jeans", "police"
];

class EnglishInflections : Inflections {
    string pluralize(string inp, int count) shared const {
        if (count == 1) {
            return inp;
        }

        foreach (s; uncountables) {
            if (inp.endsWith(s)) {
                return inp;
            }
        }

        foreach (r; plurals) {
            if (matchFirst(inp, r.regex)) {
                return replaceFirst(inp, r.regex, r.replacement);
            }
        }
        return inp;
    }
}

mixin RegisterInflections!("en", EnglishInflections);
