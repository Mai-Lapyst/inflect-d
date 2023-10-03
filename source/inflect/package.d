module inflect;

import std.traits : isSomeString;
import std.regex : Regex;

import inflect.en;

/**
 * Interface to be implemented by backends
 */
interface Inflections {
    string pluralize(string inp, int count) shared const;
}

/**
 * Execption to be throwed when a requested backend could not be found.
 */
class NoSuchInflectionsException : Exception {
    this(string locale) {
        super("Could not find inflections for '" ~ locale ~ "'");
    }
}

/**
 * Registry for inflection backends
 */
class InflectionRegistry {
    private shared(Inflections) delegate()[string] constructors;
    private shared(Inflections)[string] cache;

    private shared this() {}

    static shared(InflectionRegistry) instance() {
        static shared InflectionRegistry _instance;
        if (!_instance) {
            synchronized {
                if (!_instance) {
                    _instance = new shared(InflectionRegistry)();
                }
            }
        }
        return _instance;
    }

    synchronized void register(alias InflectionsClass)(string locale) {
        import std.traits;
        constructors[locale] = () {
            mixin(
                "return new shared(imported!\"" ~ moduleName!InflectionsClass ~ "\"." ~ InflectionsClass.stringof ~ ")();"
            );
        };
    }

    synchronized shared(Inflections) get(string locale) {
        auto p1 = locale in cache;
        if (p1 !is null) {
            return (*p1);
        }

        auto p2 = locale in constructors;
        if (p2 !is null) {
            auto i = (*p2)();
            cache[locale] = i;
            return i;
        } else {
            throw new NoSuchInflectionsException(locale);
        }
    }
}

/**
 * Helper-template to register an inflection backend
 */
template RegisterInflections(string locale, alias InflectionsClass) {
    import std.traits;
    pragma(msg, "Registering inflection for locale '" ~ locale ~ "' with type ", fullyQualifiedName!InflectionsClass);

    static this() {
        InflectionRegistry.instance().register!InflectionsClass(locale);
    }
}

/**
 * Pluralize a string
 * 
 * Params:
 *  inp = the input string
 *  count = some languages vary their pluralization based on the count; specify it here!
 *  locale = the locale to use
 */
string pluralize(S)(S inp, int count = 2, string locale = "en")
if (isSomeString!S)
{
    import std.conv : to;
    string _inp = to!string(inp);
    return InflectionRegistry.instance().get(locale).pluralize(_inp, count);
}

/// ditto
string pluralize(S)(S inp, string locale, int count = 2)
if (isSomeString!S)
{
    import std.conv : to;
    string _inp = to!string(inp);
    return InflectionRegistry.get(locale).pluralize(_inp, count);
}

unittest {
    assert("post".pluralize() == "posts");
    assert("octopus".pluralize() == "octopi");
    assert("sheep".pluralize() == "sheep");
    assert("words".pluralize() == "words");
    assert("CamelOctopus".pluralize() == "CamelOctopi");
    assert("matrix".pluralize() == "matrices");
    assert("mouse".pluralize() == "mice");
    assert("quiz".pluralize() == "quizzes");
    assert("inbox".pluralize() == "inboxes");
}
