Biodiversity
============

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3569596.svg)](https://doi.org/10.5281/zenodo.3569596)
[![Gem Version][gem_svg]][gem_link]
[![Continuous Integration Status][ci_svg]][ci_link]

Parses taxonomic scientific name and breaks it into semantic elements.

**Important**: Biodiversity parser >= 4.0.0 uses binding to
https://gitlab.com/gogna/gnparser and
is not backward compatible with older versions. However it is much much faster
and better than previous versions.

This gem does not have a remote server or a command line executable anymore.
For such features use https://gitlab.com/gogna/gnparser.

- [Biodiversity](#biodiversity)
  - [Installation](#installation)
  - [Benchmarks](#benchmarks)
  - [Example usage](#example-usage)
    - [What is "nameStringID" in the parsed results?](#what-is-%22namestringid%22-in-the-parsed-results)
  - [Copyright](#copyright)

## Installation

    sudo gem install biodiversity

The gem should work on Linux, Mac and Windows (64bit) machines

## Benchmarks

The fastest way to go through a massive amount of names is to use
`Biodiversity::Parser.parse_ary([big array], simple = true)` function.

For example parsing a large file with one name per line:

```ruby
#!/usr/bin/env ruby

require 'biodiversity'

P = Biodiversity::Parser
count = 0
File.open('all_names.txt').each_slice(50_000) do |sl|
  count += 1
  res = P.parse_ary(sl, true)
  puts count * 50_000
  puts res[0]
end
```

Here are comparative results of running parsers against a file with 24
million names on a 4CPU hyperthreaded laptop:

| Program      | Version | Full/Simple | Names/min |
| ------------ | ------- | ----------- | --------: |
| gnparser     | 0.12.0  | Simple      | 3,000,000 |
| biodiversity | 4.0.1   | Simple      | 2,000,000 |
| biodiversity | 4.0.1   | Full JSON   |   800,000 |
| biodiversity | 3.5.1   | n/a         |    40,000 |

## Example usage

You can use it as a library in Ruby:


```ruby
require 'biodiversity'

#to find the gem version number
Biodiversity.version

# Note that the version in parsed output will correspond to the version of
# gnparser.

# to parse a scientific name into a simple Ruby hash
Biodiversity::Parser.parse("Plantago major", simple = true)

# to parse many scientific names using all computer CPUs
Biodiversity::Parser.parse_ary(["Plantago major", ... ], simple = true)

# to parse a scientific name into a very detailed Ruby hash
Biodiversity::Parser.parse("Plantago major")

# to parse many scientific names with all details using all computer CPUs
Biodiversity::Parser.parse_ary(["Plantago major", ... ])

#to get json representation
Biodiversity::Parser.parse("Plantago").to_json

# to clean name up
Biodiversity::Parser.parse("      Plantago       major    ")[:normalized]


# to get canonical form with or without infraspecies ranks, as well as
# stemmed version.
parsed = Biodiversity::Parser.parse("Seddera latifolia H. & S. var. latifolia")
parsed[:canonicalName][:full]
parsed[:canonicalName][:simple]
parsed[:canonicalName][:stem]

# to get detailed information about elements of the name
Biodiversity::Parser.parse("Pseudocercospora dendrobii (H.C. Burnett 1883) U. \
Braun & Crous 2003")[:details]
```

'Surrogate' is a broad group which includes 'Barcode of Life' names, and various
undetermined names with cf. sp. spp. nr. in them:

```ruby
parser.parse("Coleoptera BOLD:1234567")[:surrogate]
```
### What is "nameStringID" in the parsed results?

ID field contains UUID v5 hexadecimal string. ID is generated out of bytes
from the name string itself, and identical id can be generated using [any
popular programming language][uuid_examples]. You can read more about UUID
version 5 in a [blog post][uuid_blog]

For example "Homo sapiens" should generate "16f235a0-e4a3-529c-9b83-bd15fe722110" UUID

Copyright
---------

Authors: [Dmitry Mozzherin][dimus]

Copyright (c) 2008-2019 Dmitry Mozzherin. See [LICENSE][license]
for further details.

[gem_svg]: https://badge.fury.io/rb/biodiversity.svg
[gem_link]: http://badge.fury.io/rb/biodiversity
[ci_svg]: https://secure.travis-ci.org/GlobalNamesArchitecture/biodiversity.svg
[ci_link]: http://travis-ci.org/GlobalNamesArchitecture/biodiversity
[dimus]: https://github.com/dimus
[license]: https://github.com/GlobalNamesArchitecture/biodiversity/blob/master/LICENSE
[uuid_examples]: https://github.com/GlobalNamesArchitecture/gn_uuid_examples
[uuid_blog]: http://globalnamesarchitecture.github.io/gna/uuid/2015/05/31/gn-uuid-0-5-0.html
