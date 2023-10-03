# inflect

A inflection library for D projects.

## License

The code in this repository is licensed under AGPL-3.0-or-later; for more details see the `LICENSE` file in the repository.

## Usage

Currently, the library only supports pluralization:
```d
import inflect;

assert("method".pluralize() == "methods");
```

Per default only the english pluralization backend is registered. To register your own:
```d
import inflect;

class MyCustomInflections : Inflections {
    string pluralize(string inp, int count) shared const {
        // ...
    }
}

mixin RegisterInflections!("my-locale", MyCustomInflections);
```

## Roadmap

- support more inflection types like singularization
- support more transformative actions like camelcase
