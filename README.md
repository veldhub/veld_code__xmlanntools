# XML annotation tools

## The objectives

This is a set of scripts to support annotation of XML documents with linguistic analysis provided by PoS/morphological taggers. Most linguistic taggers either cannot process text files with XML mark-up at all, or they have limited capabilities to process XML data directly. These scripts offer extraction of plain text contents from XML files together with a standoff representation of the original mark-up. The text and its standoff mark-up can later be merged again into the reconstructed original XML file. In-between, the plain text can also be analyzed with an external linguistic tagger and the resulting annotation can be added to the final XML file as well.

## Requirements on the tagger

Currently, two types of output from linguistic taggers is supported: 

1) general vertical format containing the annotated token at each line, followed by any amount of TAB separated attribute values; with empty lines marking sentence boundaries
2) CoNLL-U format produced by the Universal Dependencies tagger (a particular form of the general vertical format)

Generally: The tagger must be able to generate an analysis which also provides the original token strings from the analyzed texts in their original order, so that they (their position) can be directly matched in the original text. The tools provide also some limited means to handle annotation output which diverges from the original input text in some regular or otherwise deterministic way: e.g. substitution or matching of characters or tokens regularly normalized by the tagger. See section "Matching annotation with original text" below for details.

The tagger may ignore any whitespace, but all other types of characters must be included in the resulting analysis as annotated tokens. On the other hand, annotated tokens may also contain whitespace except of line breaks (the tagger must always respect linebreaks in the source plain text file as hard (paragraph) breaks - neither sentences nor tokens may cross line breaks).

## Requirements of the scripts

The scripts should work with any version of Python >= 3.6. No additional libraries beyond the ones included with Python by default are necessary.

## The result

The final merged XML file will contain additional XML mark-up according to the results of the analysis from the linguistic tagger:

1) Sentences marked with the `<s>` element (unless explicitly disabled, element name is configurable)
2) Tokens marked with the `<w>` element with arbitrarily named attributes containing the values from the PoS/morphological anlysis (amount and names of attributes are configurable; element name is configurable too)

## Typical usage

1) run `xml2standoff document.xml` to create `document.txt` and `document.json` files containg the plain text contents and description of the XML mark-up in a JSON format respectively
2) analyze the `document.txt` file using a PoS/morphological tagger resulting in a vertical/CoNLL-U file (e.g. using the provided script using the online LINDAT UDPipe 2 tagger API: `tag_ud -m english-ewt-ud-2.12-230717 -f document.txt > document.conllu`)
3) run `ann2standoff document.conllu` to convert the resulting vertical/CoNLL-U annotation into secondary standoff mark-up saved (in the JSON format) as `document.ann.json`
4) run `standoff2xml document.txt` to generate a new XML file named `document.ann.xml`, containg both the original XML mark-up and the results of the analysis in the form of added XML tags

## The main scripts and their usage in detail

All scripts provide a quick help to their usage using the option `-h`. More details can be found in the form of comments in the code. The principles, options and aims are explained here as follows.

### xml2standoff

Parses an XML file, creating two files with the same base name and the extensions `.txt` and `.json`. The first one contains all plain text contents extracted from the XML elements, the second one is a JSON array containing a list of all XML element spans (incl. XML comments and processing instructions) and their position/ranges corresponding to the extracted plain text. The plain text will include also all whitespace withing and in-between the XML elements.

By default, the text extraction is purely mechanical: everything between `<` and `>` is separated into the mark-up description and all the rest is extracted into the plain text file, incuding all whitespace, linebreaks between the elements, aso. However, in many cases, a *context aware extraction* is more desirable:

- the XML source may conatain metadata in the form of text contents, which are not meant to be analyzed (e.g. TEI header)
- the source may contain other elements or text fragments that should not be analyzed (with the same analyzer) as the rest of the text (e.g. TEI `<foreign>` elements)
- the tagger should not try to create spans (sentences or even tokens) crossing boundaries of some basic text units (usually paragraphs); in the XML format, these text units are delimited by XML tags, but those are removed by the extraction of plain text contents; taggers usually respect line breaks as hard text element boundaries which shoud not be crossed under any circumstances (or they can be forced to respect them), but the XML may not necessarily always contain line breaks between the text elements, so that any separation of the text elements disappears when the XML tags are removed (e.g. an XML fragment such as `<p>First paragraph.</p><p>Second paragraph.</p>` will result into plain text contents in the form: `First paragraph.Second paragraph.`)

For this purpose, `xml2standoff` can be used in a **context aware mode** by using the option `-t <element_names>`, where a list of comma seperated names (without spaces!) of basic text elements can be provided. In that case, the script will *only* extract plain text from the selected XML elements and all the *other* text contents will be stored separately within the stand-off description of the XML mark-up. In addition, the script ensures that additional provisional line breaks are inserted into the plain text output to separate and delimit the contents of the selected basic text units (these line breaks will be later removed in the reverse conversion by `standoff2xml`). E.g.: `-t p,head,verse`.

Selecting only particular text elements for extraction of text contents also activates automatic removal of any possible line breaks *within* their contents (their conversion into spaces). This conversion will NOT be reversed in the process of reverse conversion by the `standoff2xml` script. If this normalization is not desired, it can be suppressed using the option `-kl` (or `--keep-linebreaks`).

Text elements specified by the option `-t` may also be nested within each other. In that case, insertion of provisional line breaks also applies to such textual subelements. Unlike the top level text elements, the nested subelements will only be separated by a single line break, while the top elements are delimited by two line breaks (one at the start and one at the end of *each* text element).

Particular elements can also be **excluded** from the text extraction using the corresponding option `-e <element_names>`. When used without the option `-t`, the extraction will proceed like in the default mode - just the selected elements will be excluded from the extraction of their text contents, i.e. skipped (e.g. `-e teiHeader`). When used in combination with the option `-t`, the contents of excluded elements will be skipped if they are nested within the selected basic text elements. If the excluded elements contain further nested elements specified by the `-t` option as basic text elements, they will still be skipped within the scope of any excluded element. E.g. `-t p,head -e teiHeader,foreign` will skip all contents of `<teiHeader>` and of any `<foreign>` element (nested within the `<p>` or `<head>`), even if further `<p>` or `<head>` elements were nested deeper within their own scope.

Different approaches to extract text from TEI documents: the simplest approach is just to exclude `<teiHeader>` or just to specify `<text>` body as the single text element to extract from. However, these two methods won't secure correct line breaks in the output text file if the input TEI XML doesn't have all basic textual elements (paragraphs) also separated by line breaks. In order to ensure line break normalization of the plain text output at the level of paragraph-like text units, it is necessary to explicitly list all basic (paragraph-level) element names containing text to be tagged (e.g. `p`, `head`, `docTitle`, `docAuthor`, `docEdition`, etc.) Excluding the `<teiHeader>` may still be necessary, since it may also contain elements such as `<p>`.

### ann2standoff

Parses a vertical/CoNLL-U file and matches each analyzed token with a corresponding span in the original plain text file (expects to find the text file with the same base name and the extension `.txt` in the same directory as the vertical/CoNLL-U file). Therefore, the tokens provided by the tagger should exactly match all consequent string sequences in the original plain text file (except of whitespace, which may be ignored), in the same order. Otherwise the matching will fail.

The script is configurable either using a config file or by explictly provided command-line options. By default, the configuration file `ann2standoff.ini` is applied from the same location where the scripts are stored (if found), and possibly overriden by a configuration file with same name, located in the same directory as the processed files (if found). Additional configuration file name may be specified on the command-line (using the option `-c <file_name>`), which would override any previously found configuration. Other command-line options override the individual configuration settings obtained from the configuration files.

The configuration files may contain several profiles for several types of annotation. By default, options from the section `[DEFAULT]` are applied, overriden by any other profile explicitly specified by the command-line option `-p <profile_name>`. The section `[DEFAULT]` may also specify name of the consecutive profile to be applied by default (i.e. in case no particular profile is specified on the command-line). See the included `ann2standoff.ini` for example.

The names of configuration settings are either mentioned here or they are equal to the long names of corresponding command line options (with the initial minus signs removed and the intermediary ones replaced by underscores, e.g.: option `-t/--token-element` can be set as `token_element` in a configuration file).

For annotation in the **general vertical format**, a list of names of attributes should be provided. These names will be used as attribute names (of the resulting <w> element) for the corresponding values obtained from the vertical format in the same order. The first column must always be the string of the annotated token itself. From the second column on, the specified names will be applied as attribute names to carry the consequent values. If the vertical contains more values (TAB separated columns) than the number of attribute names provided, the attributes will be automatically named as `attr_N` (where `N` is the number of the column,counted from the second one).

For example, if the names of attributes provided contain `lemma, pos, tag` and the vertical contains the line:
`token    value1    value2  value3  value4`
then the resulting XML will later contain the following anootatio:
`<w lemma="value1" pos="value2" tag="value3" attr_4="value4">token</w>`

N.B.: When specifying the attribute names on the command-line, the names must be written in a single string separated only by commas, with no spaces! When specified in the configuration file, the names of attributes may be separated by commas, whitespace or both.

Names of the elements for tokens (`w`) and sentences (`s`) may be specified using the options `-t <element_name>` and `-s <element_name>` (or configuration options `token_element` and `sentence_element`).

For annotation in the **CoNLL-U format** (Universal Dependencies), the number and role of the attributes is fixed. Their standard names are therefore already configured in the provided `ann2standoff.ini` configuration as the `conllu` profile. In addition, a special preprocessor (`conllu`) is applied to deal with the two-level tokenization generated by the UD parser. Since the virtual "syntactic words" do not really occur in the original text file, they cannot be annotated separately. Therefore, annotation of the actually present token string must contain a merged annotation of all the "syntactic subtokens". For this purpose, the values of all the virtual subtokens are concatenated for each attribute, using either a default separator, or a special separator for that particular attribute as defined by the configuration. The  default `ann2standoff.ini` configuration example defined the symbol `|` as the default separator and `||` as separator for the attribute `feats` (since that one already uses the single `|` to separate features and their values in this multivalue attribute). Users may configure their own default separator by the configuration option `multi_separator` and any other individual separator for an attribute called `X` by a corresponding configuration option named respectively `multi_separator_X`. If no individual separator is configured for the given attribute, the default one is used.

For example, the following CoNLL-U analysis:
```
1-2 Can't   _   _   _   _   _   _   _   SpaceAfter=No
1   Ca  can AUX MD  VerbForm=Fin    0   root    _   _
2   n't not PART    RB  _   1   advmod  _   _
```
will (with the default configuration as provided in `ann2standoff.ini`) result in the following XML annotation:
`<w id="1|2" synword="Ca|n't" lemma="can|not" upos="AUX|PART" xpos="MD|RB" feats="VerbForm=Fin||_" head="0|1" deprel="root|advmod" deps="_|_" misc="_|_">Can't</w>`

Additional features of the script will be described later in the section "Matching annotation with original text".

### standoff2xml

Reads the provided plain text file and creates an XML file (with the same base name and the extension `.ann.xml`) by inserting XML annotation according to the description in the corresponding standoff metadata in JSON format as created by `xml2standoff` (expected in a file with the same base name and the extension `.json`). If the secondary standoff linguistic annotation from a PoS/morphological tagger (generated by `ann2standoff`) is found in a file with the same base name and the extension `.ann.json`, it will be merged with the original XML annotation. Any original XML elements broken by the newly inserted sentence (<s>) and token (<w>) elements will be automatically interrupted to comply with the XML specification. Sentence segmentation generated by the tagger can also be ignored and only the token annotation will be included if the option `-t` is used (useful e.g. for presegmented and sentence aligned parallel corpora).

For example, an emphasis crossing a newly inserted sentence boundary like the following:
`First sentence with <emph>emphasis. Emphasis</emph> ends in the second sentence.`
will result in a segmented text in the following form:
`<s>First sentence with <emph>emphasis.</emph></s><emph> </emph><s><emph>Emphasis</emph> ends in the second sentence.</s>`
(For simplification, the word-level/token annotation is not presented in this example.)

Any breaking of original XML elements by the annotation can be reported as warnings if the option `-Wb <element_list>` is used. The `<element-list>` is a comma separated list of XML elements that do NOT need to be reported (exceptions). E.g. using the option `-Wb emph,hi,i,u,b`, the script will issue a warning in case some XML element is broken *other* than `<emph>`, `<hi>`, `<i>`, `<u>` or `<b>`. (While breaking emphasis or other highlighting in the text usually does not matter, breaking other text structures may indicate a problem.) If the option `-Wb` is not used, no warnings are issued at all.

The word-level/token annotation will be preferably inserted/nested into the original XML mark-up wherever possible, e.g.: `<emph><w lemma="reactivation">reactivations</w></emph>`. However, if the original XML annotation applies only to a part of the newly identified token, the elements can only be nested the other way: `<w lemma="reactivation"><emph>re</emph>activation</w>`.

## Matching annotation with original text

As mentioned above, the tagger is expected to return token annotation including the exact token string as it occurs in the original text file, so that the token annotation can be matched and applied to the original text span and any possible original whitespace is correctly preserved.

Whitespace between tokens is an exception and will be automatically skipped by the script. However, the Unicode standard covers a wide range of whitespace characters and some of them may also be treated as (parts of) tokens by some taggers. Therefore, only basic ASCII whitespace (i.e. the characters SPACE, TAB, CR and LF) is removed from the vertical annotation before matching it to the refrence text. The option `-us` activates standard Python stripping of all unicode whitespace.

Even taggers preserving correctly most of the original strings sometimes apply some kind of normalization. E.g. normalization of various unicode quotation marks or other typographic punctuation symbols into their basic ASCII correspondence. For this purpose, a list of all possible matches may be provided by the user, so that the script can match a token presented by the tagger with its various relializations that may actually occur in the original text. The list should be provided in a separate TSV file (TAB separated values) using the option `-m <filename>` (or the corresponding configuration attribute `matches`). The first column fo each line in the TSV file should contain the particular token string as output by the tagger, all following columns may contain all the possible corresponding strings that should be matched as various realizations/correspondences of this token. The number of TAB separated values (columns) is not limited. If the token string should also match itself, it should also be listed again among the variants.

For example, a line containing various possible textual realizations of a double quotation mark normalized by a tagger into the basic ASCII symbol:
```
"   "   “   ”   „    ‟    «   »
```

While the list of possible matches provides a simple method to match 1 token to N of its possible realizations in the original text, sometimes a more advanced method is needed to match different systematically transformed tagger outputs to the original textual strings. For this purpose, another external file with a list of replacements may also be provided in the form of a TSV file, where the first column contains a regular expression and the second column its replacement. These replacements will then be applied to each token output by the tagger *before* it is matched to the original reference text contents. The replacement string may also contain backreferences to substrings matched by the regular expression (e.g. `\1` to refer to the first group matched by the regular expression). In order to match the whole token, the regular expression should also contain the anchors `^` at the beginning and `$` at the end.

The table of replacements is applied using the option `-r <filename>` or the correspodning configuration attribute `replacements`.

## Treatment of entities

In the process of plain text extraction within `xml2standoff`, the [standard Python method `html.unescape()`](https://docs.python.org/3/library/html.html) is applied to the contents, which ensures conversion of standard named and numeric entities into the corresponding unicode characters. Thus, the plain text output shouldn't contain any (standard) entities.

In the reverse conversion within `standoff2xml`, the corresponding method `html.escape()` (see link above again) is applied to the text contents. However, this conversion does NOT reverse the process to reconstruct all the original entities! It only converts the basic characters conflicting with XML mark-up (i.e. `<`, `>` and `&`) into their corresponding entities.

## Additional scripts

### tag_ud

A simple feeder sending the input text in batches to the LINDAT online analyzer for Universal Dependencies (UDPipe 2). By default, it reads the standard input (STDIN), but using the option `-f <filename>`, the input can be read from the specified file. The option `-m <model>` specifies the UD language model to be applied for analysis. The default batch size of 1000 lines can be changed to any custom number using the option `-b <number>` (the API has some limit for a maximal request size, so it can't process arbitrarily large texts at once). See the [UDPipe website](https://lindat.mff.cuni.cz/services/udpipe/) for more details about the process and the REST API.

The resulting CoNLL-U vertical is output to the standard output (STDOUT). Use redirection to save it into a file, e.g. `tag_ud -m english-ewt-ud-2.12-230717 -f document.txt >document.conllu`.

The option `-v` reports some basic information about the progress to the standard error output (STDERR).

### xml2vrt

Script to convert the final, complete and fully tagged XML (e.g. `.ann.xml` output from `standoff2xml`) into vertical format. It shares the same configuration (`ann2standoff.ini`) as `ann2standoff`, but not all options are shared (actually only `attributes` and `token_element`). It also uses the option `-c` and `-p` in the same way.

The extracted type of vertical may be identical to the one produced by the tagger or it may be limited to fewer attributes. If no attribute names are given or their amount is lower than the actual number of attributes present, it tries to automatically include the attributes with default names `attr_N` as generated by `ann2standoff`. In that way, it shouldn't be necessary to provide a list of attribute names (nor their amount) to these two scripts if the only goal is to get the same vertical as produced by the tagger, just with the original XML annotation added. (If there is a combination of both explicitly named *and* automatically numbered attributes, the latter ones will only be included if their numbers follow the amount of the named ones exactly, e.g. `lemma, pos, attr_3, attr_4`.)

By default, the script will generate a so called "glue" element `<g/>` between tokens, where there was no space separating them in the original text flow (eg. between a word and a punctuation symbol). The name of the glue element can be changed using the option `-g <name>` ('g' by default). Inserting the glue element can also be disabled using the option `-ng` (or `--no-glue`).

By default, the script will automatically remove tags within the token string itself as well as any empty elements anywhere in the vertical (recursively), since such elements are usually not supported by search engines using the vertical format. This behaviour may be suppressed using the options `-kt` (or `--keep-token-tags`) and `-ke` (or `--keep_empty`) respectively.

If there are text contents found within elements other than the specified token element ('w' by default, can be specified using the option `-t <name>`, configuration option `token_element`), the whole fragments are output as single line "tokens" by default. Using the option `-df` (or `--discard-freetext`) they will be just discarded from the output.

By default, the whole root element of the XML file will be extracted into the vertical. If just some particular subelements should be extracted, they can be specified using the option `-i <element_names>` (where element names are again listed as a single, comma separated list without spaces) or the configuration option `include_elements` (here, whitespace is allowed too). These elements are *not* expected to be nested within each other.

Particular elements can also be excluded from the extraction using the option `-e <element_names>` or the configuration option `exclude_elements`. These elements may also be nested.

The script is also capable of extracting an XML fragment file (i.e. a document missing a common XML root element) by using the option `-F`. For the purpose of processing, the contents will internally be wrapped into a temporary wrapper root element, which will not appear in the resulting vertical.