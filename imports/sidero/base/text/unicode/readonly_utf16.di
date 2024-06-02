// D import file generated from 'generated\sidero\base\text\unicode\readonly_utf16.d'
module sidero.base.text.unicode.readonly_utf16;
import sidero.base.text.unicode.defs;
import sidero.base.text.unicode.characters.database;
import sidero.base.text;
import sidero.base.encoding.utf;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.traits : isUTFReadOnly;
import sidero.base.attributes : hidden;
import sidero.base.internal.atomic;
export struct String_UTF16
{
	package(sidero.base.text.unicode)
	{
		const(void)[] literal;
		UnicodeEncoding literalEncoding;
		UnicodeLanguage language;
		size_t lifeTime;
		size_t iterator;
	}
	private @(hidden)
	{
		import sidero.base.internal.meta : OpApplyCombos;
	}
	export
	{
		alias Char = wchar;
		alias LiteralType = const(Char)[];
		mixin OpApplyCombos!(Char, void, "opApply", true, true, true, false, false);
		mixin OpApplyCombos!(Char, void, "opApplyReverse", true, true, true, false, false);
		nothrow @nogc
		{
			@system const(Char)* ptr();
			@system const(Char)[] unsafeGetLiteral();
			alias save = opSlice;
			scope @trusted typeof(this) opSlice();
			scope @trusted typeof(this) opSlice(ptrdiff_t start, ptrdiff_t end);
			scope @trusted typeof(this) withoutIterator();
			@safe
			{
				scope @trusted void opAssign(scope const(char)[] literal);
				scope @trusted void opAssign(scope const(wchar)[] literal);
				scope @trusted void opAssign(scope const(dchar)[] literal);
				scope @trusted void opAssign(return scope typeof(this) other);
				@disable const scope void opAssign(scope const(char)[] other);
				@disable const scope void opAssign(scope const(wchar)[] other);
				@disable const scope void opAssign(scope const(dchar)[] other);
				@disable const scope void opAssign(return scope typeof(this) other);
				scope @trusted this(ref return scope typeof(this) other);
				scope @disable const this(ref return scope const typeof(this) other);
				scope @trusted
				{
					this(return scope const(char)[] literal, return scope RCAllocator allocator = RCAllocator.init, return scope const(char)[] toDeallocate = null, UnicodeLanguage language = UnicodeLanguage.Unknown);
					this(return scope const(wchar)[] literal, return scope RCAllocator allocator = RCAllocator.init, return scope const(wchar)[] toDeallocate = null, UnicodeLanguage language = UnicodeLanguage.Unknown);
					this(return scope const(dchar)[] literal, return scope RCAllocator allocator = RCAllocator.init, return scope const(dchar)[] toDeallocate = null, UnicodeLanguage language = UnicodeLanguage.Unknown);
					~this();
				}
				const scope bool isNull();
				scope bool haveIterator();
				scope bool isPtrNullTerminated();
				const scope bool isEncodingChanged();
				const scope UnicodeLanguage unicodeLanguage();
				scope void unicodeLanguage(UnicodeLanguage language);
				alias opDollar = length;
				const scope ptrdiff_t length();
				@nogc scope size_t encodingLength();
				static if (is(Char == char))
				{
					const scope @trusted StringBuilder_UTF8 asMutable(RCAllocator allocator = RCAllocator.init);
				}
				else
				{
					static if (is(Char == wchar))
					{
						const scope @trusted StringBuilder_UTF16 asMutable(RCAllocator allocator = RCAllocator.init);
					}
					else
					{
						static if (is(Char == dchar))
						{
							const scope @trusted StringBuilder_UTF32 asMutable(RCAllocator allocator = RCAllocator.init);
						}
					}
				}
				scope @trusted typeof(this) dup(RCAllocator allocator = RCAllocator.init);
				scope @trusted typeof(this) normalize(bool compatibility = false, bool compose = false, UnicodeLanguage language = UnicodeLanguage.Unknown, RCAllocator allocator = RCAllocator.init);
				typeof(this) toNFD(UnicodeLanguage language = UnicodeLanguage.Unknown, RCAllocator allocator = RCAllocator.init);
				typeof(this) toNFC(UnicodeLanguage language = UnicodeLanguage.Unknown, RCAllocator allocator = RCAllocator.init);
				typeof(this) toNFKD(UnicodeLanguage language = UnicodeLanguage.Unknown, RCAllocator allocator = RCAllocator.init);
				typeof(this) toNFKC(UnicodeLanguage language = UnicodeLanguage.Unknown, RCAllocator allocator = RCAllocator.init);
				scope typeof(this) opIndex(ptrdiff_t index);
				const scope bool opCast(T : bool)()
				{
					return !isNull;
				}
				auto @disable opCast(T)();
				alias equals = opEquals;
				const scope bool opEquals(scope const(char)[] other);
				const scope bool opEquals(scope const(wchar)[] other);
				const scope bool opEquals(scope const(dchar)[] other);
				const scope bool opEquals(scope String_UTF8 other);
				const scope bool opEquals(scope String_UTF16 other);
				const scope bool opEquals(scope String_UTF32 other);
				const scope bool opEquals(scope String_ASCII other);
				const scope @trusted bool opEquals(scope StringBuilder_UTF8 other);
				const scope @trusted bool opEquals(scope StringBuilder_UTF16 other);
				const scope @trusted bool opEquals(scope StringBuilder_UTF32 other);
				const scope @trusted bool opEquals(scope StringBuilder_ASCII other);
				const scope @trusted bool ignoreCaseEquals(scope const(char)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope const(wchar)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope const(dchar)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted bool ignoreCaseEquals(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				alias compare = opCmp;
				const scope @trusted int opCmp(scope const(char)[] other);
				const scope @trusted int opCmp(scope const(wchar)[] other);
				const scope @trusted int opCmp(scope const(dchar)[] other);
				const scope @trusted int opCmp(scope String_ASCII other);
				const scope @trusted int opCmp(scope String_UTF8 other);
				const scope @trusted int opCmp(scope String_UTF16 other);
				const scope @trusted int opCmp(scope String_UTF32 other);
				const scope @trusted int opCmp(scope StringBuilder_UTF8 other);
				const scope @trusted int opCmp(scope StringBuilder_UTF16 other);
				const scope @trusted int opCmp(scope StringBuilder_UTF32 other);
				const scope @trusted int opCmp(scope StringBuilder_ASCII other);
				const scope @trusted int ignoreCaseCompare(scope const(char)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope const(wchar)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope const(dchar)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope @trusted int ignoreCaseCompare(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				nothrow @nogc scope bool empty();
				scope @trusted Char front();
				scope @trusted Char back();
				scope void popFront();
				scope void popBack();
				scope @trusted String_UTF8 byUTF8() return;
				scope @trusted String_UTF16 byUTF16() return;
				scope @trusted String_UTF32 byUTF32() return;
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope const(char)[] other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope const(wchar)[] other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope const(dchar)[] other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope String_UTF8 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope String_UTF16 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope String_UTF32 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope String_ASCII other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope StringBuilder_UTF8 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope StringBuilder_UTF16 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope StringBuilder_UTF32 other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope @trusted StringBuilder_UTF!Char opBinary(string op : "~")(scope StringBuilder_ASCII other)
				{
					StringBuilder_UTF!Char ret;
					ret ~= this;
					ret ~= other;
					return ret;
				}
				scope bool startsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool startsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool startsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool ignoreCaseStartsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool endsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool endsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init);
				scope bool ignoreCaseEndsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t count(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_ASCII input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope @trusted typeof(this) strip() return;
				scope typeof(this) stripLeft() return;
				scope typeof(this) stripRight() return;
				const scope StringBuilder_UTF!Char toLower(RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope StringBuilder_UTF!Char toUpper(RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope StringBuilder_UTF!Char toTitle(RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope ulong toHash();
				scope void stripZeroTerminator();
				package(sidero.base.text) @(hidden)
				{
					const scope @trusted RCAllocator pickAllocator(return scope RCAllocator given);
					const scope UnicodeLanguage pickLanguage(UnicodeLanguage input = UnicodeLanguage.Unknown);
					scope
					{
						void changeIndexToOffset(ref ptrdiff_t a);
						void changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b);
						bool ignoreCaseEqualsImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
						bool ignoreCaseEqualsImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								return other.isNull;
							}
							) == 0;
						}
						int opCmpImplSlice(Char2)(scope const(Char2)[] other)
						{
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return other.length > 0 ? -1 : 0;
							int matches(Type)(Type us)
							{
								if (us.length > 0 && (us[$ - 1] == '\0'))
									us = us[0..$ - 1];
								if (us.length < other.length)
									return -1;
								else if (us.length > other.length)
									return 1;
								foreach (i; 0 .. us.length)
								{
									if (us[i] < other[i])
										return -1;
									else if (us[i] > other[i])
										return 1;
								}
								return 0;
							}
							int needDecode(Type)(Type us)
							{
								if (us.length > 0 && (us[$ - 1] == '\0'))
									us = us[0..$ - 1];
								while (us.length > 0 && (other.length > 0))
								{
									dchar usC, otherC;
									static if ((typeof(us[0])).sizeof == 4)
									{
										usC = us[0];
										us = us[1..$];
									}
									else
									{
										us = us[decode(us, usC)..$];
									}
									static if ((typeof(other[0])).sizeof == 4)
									{
										otherC = other[0];
										other = other[1..$];
									}
									else
									{
										other = other[decode(other, otherC)..$];
									}
									if (usC < otherC)
										return -1;
									else if (usC > otherC)
										return 1;
								}
								if (us.length == 0)
									return other.length == 0 ? 0 : -1;
								else
									return 1;
							}
							return literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])this.literal;
								static if ((typeof(other[0])).sizeof == (char).sizeof)
								{
									return matches(actual);
								}
								else
								{
									return needDecode(actual);
								}
							}
							, ()
							{
								auto actual = cast(const(wchar)[])this.literal;
								static if ((typeof(other[0])).sizeof == (wchar).sizeof)
								{
									return matches(actual);
								}
								else
								{
									return needDecode(actual);
								}
							}
							, ()
							{
								auto actual = cast(const(dchar)[])this.literal;
								static if ((typeof(other[0])).sizeof == (dchar).sizeof)
								{
									return matches(actual);
								}
								else
								{
									return needDecode(actual);
								}
							}
							, ()
							{
								return other.length > 0 ? -1 : 0;
							}
							);
						}
						int opCmpImplReadOnly(scope String_ASCII other);
						int opCmpImplReadOnly(Other)(scope Other other) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return opCmpImplSlice(actual);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return opCmpImplSlice(actual);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return opCmpImplSlice(actual);
							}
							);
						}
						int opCmpImplBuilder(scope StringBuilder_ASCII other);
						int ignoreCaseCompareImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
						int ignoreCaseCompareImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return ignoreCaseCompareImplSlice(actual, allocator, language);
							}
							, ()
							{
								return other.length > 0 ? -1 : 0;
							}
							);
						}
						@trusted int ignoreCaseCompareImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return other.length > 0 ? -1 : 0;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF usH, otherH = foreachOverAnyUTF(other);
							literalEncoding.handle(() @trusted
							{
								auto actual = cast(const(char)[])this.literal;
								if (actual.length > 0 && (actual[$ - 1] == '\0'))
									actual = actual[0..$ - 1];
								usH = foreachOverAnyUTF(actual);
							}
							, () @trusted
							{
								auto actual = cast(const(wchar)[])this.literal;
								if (actual.length > 0 && (actual[$ - 1] == '\0'))
									actual = actual[0..$ - 1];
								usH = foreachOverAnyUTF(actual);
							}
							, () @trusted
							{
								auto actual = cast(const(dchar)[])this.literal;
								if (actual.length > 0 && (actual[$ - 1] == '\0'))
									actual = actual[0..$ - 1];
								usH = foreachOverAnyUTF(actual);
							}
							);
							return icmpUTF32_NFD(&usH.opApply, &otherH.opApply, allocator, language.isTurkic);
						}
						@trusted int ignoreCaseCompareImplBuilder(scope StringBuilder_ASCII other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown);
						@trusted bool startsWithImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return other.length == 0;
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							scope tempUs32 = this.byUTF32();
							tempUs32.stripZeroTerminator;
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							return comparison.compare(&tempUs32.opApply, true) == 0;
						}
						bool startsWithImplStrReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						bool startsWithImplStrReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return startsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return startsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return startsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return other.isNull;
							}
							);
						}
						@trusted bool endsWithImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return false;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							const numberOfCharactersNeeded = comparison.againstLength();
							const toConsumeLength = literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])this.literal;
								return codePointsFromEnd(actual, numberOfCharactersNeeded);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])this.literal;
								return codePointsFromEnd(actual, numberOfCharactersNeeded);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])this.literal;
								return codePointsFromEnd(actual, numberOfCharactersNeeded);
							}
							);
							if (toConsumeLength == 0)
							{
								return toConsumeLength == other.length;
							}
							const offsetForUs = this.length - toConsumeLength;
							scope tempUs32 = this[offsetForUs..offsetForUs + toConsumeLength].byUTF32();
							tempUs32.stripZeroTerminator;
							return comparison.compare(&tempUs32.opApply, true) == 0;
						}
						bool endsWithImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						bool endsWithImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return endsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return endsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return endsWithImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return other.isNull;
							}
							);
						}
						@trusted size_t countImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return 0;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							const lengthOfOther = comparison.againstLength();
							size_t total;
							typeof(this) us = this;
							us.stripZeroTerminator;
							while (us.length > 0)
							{
								size_t toIncrease = 1;
								scope tempUs = us.byUTF32();
								if (comparison.compare(&tempUs.opApply, true) == 0)
								{
									toIncrease = lengthOfOther;
									total++;
								}
								foreach (i; 0 .. toIncrease)
								{
									const characterLength = us.literalEncoding.handle(()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(char)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(wchar)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? 1 : 0;
									}
									);
									us = us[characterLength..$];
								}
							}
							return total;
						}
						size_t countImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						size_t countImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return countImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return countImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return countImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return 0;
							}
							);
						}
						@trusted bool containsImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return false;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							const lengthOfOther = comparison.againstLength();
							typeof(this) us = this;
							us.stripZeroTerminator;
							while (us.length > 0)
							{
								size_t toIncrease = 1;
								scope tempUs = us.byUTF32();
								if (comparison.compare(&tempUs.opApply, true) == 0)
								{
									return true;
								}
								foreach (i; 0 .. toIncrease)
								{
									const characterLength = us.literalEncoding.handle(()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(char)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(wchar)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? 1 : 0;
									}
									);
									us = us[characterLength..$];
								}
							}
							return false;
						}
						bool containsImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						bool containsImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return containsImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return containsImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return containsImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return other.isNull;
							}
							);
						}
						@trusted ptrdiff_t indexofImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return -1;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							const lengthOfOther = comparison.againstLength();
							ptrdiff_t ret;
							typeof(this) us = this;
							us.stripZeroTerminator;
							while (us.length > 0)
							{
								size_t toIncrease = 1;
								scope tempUs = us.byUTF32();
								if (comparison.compare(&tempUs.opApply, true) == 0)
								{
									return ret;
								}
								foreach (i; 0 .. toIncrease)
								{
									const characterLength = us.literalEncoding.handle(()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(char)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(wchar)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? 1 : 0;
									}
									);
									us = us[characterLength..$];
									ret += characterLength;
								}
							}
							return -1;
						}
						ptrdiff_t indexOfImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						ptrdiff_t indexOfImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return indexofImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return indexofImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return indexofImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return -1;
							}
							);
						}
						@trusted ptrdiff_t lastIndexOfImplSlice(Char2)(scope const(Char2)[] other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown)
						{
							import sidero.base.text.unicode.comparison : CaseAwareComparison;
							if (other.length > 0 && (other[$ - 1] == '\0'))
								other = other[0..$ - 1];
							if (isNull)
								return -1;
							language = pickLanguage(language);
							allocator = pickAllocator(allocator);
							scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(other);
							scope comparison = CaseAwareComparison(allocator, language.isTurkic);
							comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
							const lengthOfOther = comparison.againstLength();
							ptrdiff_t ret = -1, soFar;
							typeof(this) us = this;
							us.stripZeroTerminator;
							while (us.length > 0)
							{
								size_t toIncrease = 1;
								scope tempUs = us.byUTF32();
								if (comparison.compare(&tempUs.opApply, true) == 0)
								{
									ret = soFar;
									toIncrease = lengthOfOther;
								}
								foreach (i; 0 .. toIncrease)
								{
									const characterLength = us.literalEncoding.handle(()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(char)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? decodeLength((cast(const(wchar)[])us.literal)[0]) : 0;
									}
									, ()
									{
										return us.literal.length > 0 ? 1 : 0;
									}
									);
									us = us[characterLength..$];
									soFar += characterLength;
								}
							}
							return ret;
						}
						ptrdiff_t lastIndexOfImplReadOnly(scope String_ASCII other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown);
						ptrdiff_t lastIndexOfImplReadOnly(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) if (isUTFReadOnly!Other)
						{
							return other.literalEncoding.handle(()
							{
								auto actual = cast(const(char)[])other.literal;
								return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(wchar)[])other.literal;
								return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								auto actual = cast(const(dchar)[])other.literal;
								return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
							}
							, ()
							{
								return -1;
							}
							);
						}
						@trusted void primeForwards();
						@trusted void popFrontImpl();
						@trusted void primeBackwards();
						@trusted void popBackImpl();
					}
				}
			}
		}
	}
}
