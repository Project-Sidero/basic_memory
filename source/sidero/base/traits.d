///
module sidero.base.traits;
import sidero.base.text.ascii.readonly;
import sidero.base.text.ascii.builder;
import sidero.base.text.unicode.readonly;
import sidero.base.text.unicode.builder;

///
enum isReadOnlyString(String) = is(String == String_ASCII) || is(String == String_UTF!Char, Char);
///
enum isBuilderString(String) = is(String == StringBuilder_ASCII) || is(String == StringBuilder_UTF!Char, Char);

///
enum isASCII(String) = is(String == String_ASCII) || is(String == StringBuilder_ASCII);
///
enum isUTF(String) = is(String == String_UTF!Char, Char) || is(String == StringBuilder_UTF!Char, Char);
