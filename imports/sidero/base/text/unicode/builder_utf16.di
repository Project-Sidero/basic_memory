// D import file generated from 'generated\sidero\base\text\unicode\builder_utf16.d'
module sidero.base.text.unicode.builder_utf16;
import sidero.base.text.unicode.internal.builder;
import sidero.base.text.unicode.characters.database : UnicodeLanguage;
import sidero.base.text;
import sidero.base.allocators.api;
import sidero.base.attributes : hidden;
export struct StringBuilder_UTF16
{
	alias Char = wchar;
	alias LiteralType = const(Char)[];
	private
	{
		import sidero.base.internal.meta : OpApplyCombos;
		template opApplyImpl(Del)
		{
			@(hidden)scope int opApplyImpl(scope Del del)
			{
				return state.opApplyImpl!Char(del);
			}
		}
		template opApplyReverseImpl(Del)
		{
			@(hidden)scope int opApplyReverseImpl(scope Del del)
			{
				return state.opApplyReverseImpl!Char(del);
			}
		}
	}
	export
	{
		mixin OpApplyCombos!(Char, void, "opApply", true, true, true, false, false);
		mixin OpApplyCombos!(Char, void, "opApplyReverse", true, true, true, false, false);
		nothrow @safe
		{
			@nogc scope void opAssign(ref return scope typeof(this) other);
			@nogc scope void opAssign(return scope typeof(this) other);
			@disable const scope void opAssign(ref return scope typeof(this) other);
			@disable const scope void opAssign(return scope typeof(this) other);
			auto @disable opCast(T)();
			scope @nogc scope @trusted this(ref return scope typeof(this) other);
			scope @disable const scope @safe this(ref return scope typeof(this) other);
			@disable const this(const ref typeof(this) other);
			scope @nogc scope this(RCAllocator allocator);
			scope @nogc scope this(RCAllocator allocator, scope const(char)[] input...);
			scope @nogc scope this(RCAllocator allocator, scope const(wchar)[] input...);
			scope @nogc scope this(RCAllocator allocator, scope const(dchar)[] input...);
			scope @nogc scope this(RCAllocator allocator, scope String_ASCII input);
			scope @nogc scope this(RCAllocator allocator, scope String_UTF8 input = String_UTF8.init);
			scope @nogc scope this(RCAllocator allocator, scope String_UTF16 input = String_UTF16.init);
			scope @nogc scope this(RCAllocator allocator, scope String_UTF32 input = String_UTF32.init);
			scope @nogc scope this(scope const(char)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
			scope @nogc scope this(scope const(wchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
			scope @nogc scope this(scope const(dchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
			scope @nogc scope @trusted this(scope String_ASCII input, RCAllocator allocator = RCAllocator.init);
			scope @nogc scope @trusted this(scope String_UTF8 input, RCAllocator allocator = RCAllocator.init);
			scope @nogc scope @trusted this(scope String_UTF16 input, RCAllocator allocator = RCAllocator.init);
			scope @nogc scope @trusted this(scope String_UTF32 input, RCAllocator allocator = RCAllocator.init);
			scope @nogc ~this();
			const @nogc scope @trusted bool isNull();
			@nogc scope bool haveIterator();
			@nogc scope @trusted typeof(this) withoutIterator();
			const scope bool isEncodingChanged();
			scope UnicodeLanguage unicodeLanguage();
			@nogc scope typeof(this) opIndex(ptrdiff_t index);
			@nogc scope @trusted typeof(this) save();
			alias opSlice = save;
			@nogc scope typeof(this) opSlice(ptrdiff_t start, ptrdiff_t end);
			alias opDollar = length;
			const @nogc scope @trusted ptrdiff_t length();
			@nogc scope size_t encodingLength();
			const @nogc scope @trusted typeof(this) dup(return scope RCAllocator allocator = RCAllocator.init);
			@nogc scope String_UTF!Char asReadOnly(RCAllocator allocator = RCAllocator.init);
			const @nogc scope typeof(this) asMutable(return scope RCAllocator allocator = RCAllocator.init);
			@nogc
			{
				scope @trusted typeof(this) normalize(bool compatibility, bool composition, UnicodeLanguage language);
				scope typeof(this) toNFD(UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope typeof(this) toNFC(UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope typeof(this) toNFKD(UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope typeof(this) toNFKC(UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			const @nogc scope bool opCast(T : bool)()
			{
				return !isNull;
			}
			auto @disable opCast(T)();
			alias equals = opEquals;
			@nogc
			{
				const scope bool opEquals(scope const(char)[] other);
				const scope bool opEquals(scope const(wchar)[] other);
				const scope bool opEquals(scope const(dchar)[] other);
				const scope bool opEquals(scope String_ASCII other);
				const scope bool opEquals(scope String_UTF8 other);
				const scope bool opEquals(scope String_UTF16 other);
				const scope bool opEquals(scope String_UTF32 other);
				const scope bool opEquals(scope StringBuilder_ASCII other);
				const scope bool opEquals(scope StringBuilder_UTF8 other);
				const scope bool opEquals(scope StringBuilder_UTF16 other);
				const scope bool opEquals(scope StringBuilder_UTF32 other);
			}
			@nogc
			{
				const scope bool ignoreCaseEquals(scope const(char)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope const(wchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope const(dchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope String_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope String_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope String_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope String_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope bool ignoreCaseEquals(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			alias compare = opCmp;
			@nogc
			{
				const scope int opCmp(scope const(char)[] other);
				const scope int opCmp(scope const(wchar)[] other);
				const scope int opCmp(scope const(dchar)[] other);
				const scope int opCmp(scope String_ASCII other);
				const scope int opCmp(scope String_UTF8 other);
				const scope int opCmp(scope String_UTF16 other);
				const scope int opCmp(scope String_UTF32 other);
				const scope int opCmp(scope StringBuilder_ASCII other);
				const scope int opCmp(scope StringBuilder_UTF8 other);
				const scope int opCmp(scope StringBuilder_UTF16 other);
				const scope int opCmp(scope StringBuilder_UTF32 other);
			}
			@nogc
			{
				const scope int ignoreCaseCompare(scope const(char)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope const(wchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope const(dchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope String_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope String_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope String_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope String_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
				const scope int ignoreCaseCompare(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			alias put = append;
			@nogc scope bool empty();
			@nogc scope Char front();
			@nogc scope Char back();
			@nogc scope void popFront();
			@nogc scope void popBack();
			@nogc scope @trusted StringBuilder_UTF8 byUTF8();
			@nogc scope @trusted StringBuilder_UTF16 byUTF16();
			@nogc scope @trusted StringBuilder_UTF32 byUTF32();
			@nogc
			{
				scope bool startsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool startsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			@nogc
			{
				scope bool ignoreCaseStartsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseStartsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			@nogc
			{
				scope bool endsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool endsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			@nogc
			{
				scope bool ignoreCaseEndsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseEndsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			@nogc
			{
				scope size_t count(scope const(char)[] toFind);
				scope size_t count(scope const(wchar)[] toFind);
				scope size_t count(scope const(dchar)[] toFind);
				scope size_t count(scope String_ASCII toFind);
				scope size_t count(scope String_UTF8 toFind);
				scope size_t count(scope String_UTF16 toFind);
				scope size_t count(scope String_UTF32 toFind);
				scope size_t count(scope StringBuilder_ASCII toFind);
				scope size_t count(scope StringBuilder_UTF8 toFind);
				scope size_t count(scope StringBuilder_UTF16 toFind);
				scope size_t count(scope StringBuilder_UTF32 toFind);
				scope size_t ignoreCaseCount(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t ignoreCaseCount(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool contains(scope const(char)[] toFind);
				scope bool contains(scope const(wchar)[] toFind);
				scope bool contains(scope const(dchar)[] toFind);
				scope bool contains(scope String_ASCII toFind);
				scope bool contains(scope String_UTF8 toFind);
				scope bool contains(scope String_UTF16 toFind);
				scope bool contains(scope String_UTF32 toFind);
				scope bool contains(scope StringBuilder_ASCII toFind);
				scope bool contains(scope StringBuilder_UTF8 toFind);
				scope bool contains(scope StringBuilder_UTF16 toFind);
				scope bool contains(scope StringBuilder_UTF32 toFind);
				scope bool ignoreCaseContains(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope bool ignoreCaseContains(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t indexOf(scope const(char)[] toFind);
				scope ptrdiff_t indexOf(scope const(wchar)[] toFind);
				scope ptrdiff_t indexOf(scope const(dchar)[] toFind);
				scope ptrdiff_t indexOf(scope String_ASCII toFind);
				scope ptrdiff_t indexOf(scope String_UTF8 toFind);
				scope ptrdiff_t indexOf(scope String_UTF16 toFind);
				scope ptrdiff_t indexOf(scope String_UTF32 toFind);
				scope ptrdiff_t indexOf(scope StringBuilder_ASCII toFind);
				scope ptrdiff_t indexOf(scope StringBuilder_UTF8 toFind);
				scope ptrdiff_t indexOf(scope StringBuilder_UTF16 toFind);
				scope ptrdiff_t indexOf(scope StringBuilder_UTF32 toFind);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t lastIndexOf(scope const(char)[] toFind);
				scope ptrdiff_t lastIndexOf(scope const(wchar)[] toFind);
				scope ptrdiff_t lastIndexOf(scope const(dchar)[] toFind);
				scope ptrdiff_t lastIndexOf(scope String_ASCII toFind);
				scope ptrdiff_t lastIndexOf(scope String_UTF8 toFind);
				scope ptrdiff_t lastIndexOf(scope String_UTF16 toFind);
				scope ptrdiff_t lastIndexOf(scope String_UTF32 toFind);
				scope ptrdiff_t lastIndexOf(scope StringBuilder_ASCII toFind);
				scope ptrdiff_t lastIndexOf(scope StringBuilder_UTF8 toFind);
				scope ptrdiff_t lastIndexOf(scope StringBuilder_UTF16 toFind);
				scope ptrdiff_t lastIndexOf(scope StringBuilder_UTF32 toFind);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			@nogc
			{
				scope typeof(this) strip() return;
				scope typeof(this) stripLeft() return;
				scope typeof(this) stripRight() return;
			}
			@nogc
			{
				scope typeof(this) toLower(UnicodeLanguage language = UnicodeLanguage.Unknown) return;
				scope typeof(this) toUpper(UnicodeLanguage language = UnicodeLanguage.Unknown) return;
				scope typeof(this) toTitle(UnicodeLanguage language = UnicodeLanguage.Unknown) return;
			}
			@nogc scope void remove(ptrdiff_t index, size_t amount);
			@nogc scope void clear();
			@nogc
			{
				scope typeof(this) insert(ptrdiff_t index, scope const(char)[] input...) return;
				scope typeof(this) insert(ptrdiff_t index, scope const(wchar)[] input...) return;
				scope typeof(this) insert(ptrdiff_t index, scope const(dchar)[] input...) return;
				scope typeof(this) insert(ptrdiff_t index, scope String_ASCII input) return;
				scope typeof(this) insert(ptrdiff_t index, scope String_UTF8 input) return;
				scope typeof(this) insert(ptrdiff_t index, scope String_UTF16 input) return;
				scope typeof(this) insert(ptrdiff_t index, scope String_UTF32 input) return;
				scope typeof(this) insert(ptrdiff_t index, scope StringBuilder_ASCII input) return;
				scope typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF8 input) return;
				scope typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF16 input) return;
				scope typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF32 input) return;
			}
			@nogc
			{
				scope @trusted typeof(this) prepend(scope const(char)[] input...) return;
				scope @trusted typeof(this) prepend(scope const(wchar)[] input...) return;
				scope @trusted typeof(this) prepend(scope const(dchar)[] input...) return;
				scope @trusted typeof(this) prepend(scope String_ASCII input) return;
				scope @trusted typeof(this) prepend(scope String_UTF8 input) return;
				scope @trusted typeof(this) prepend(scope String_UTF16 input) return;
				scope @trusted typeof(this) prepend(scope String_UTF32 input) return;
				scope @trusted typeof(this) prepend(scope StringBuilder_ASCII input) return;
				scope @trusted typeof(this) prepend(scope StringBuilder_UTF8 input) return;
				scope @trusted typeof(this) prepend(scope StringBuilder_UTF16 input) return;
				scope @trusted typeof(this) prepend(scope StringBuilder_UTF32 input) return;
			}
			@nogc
			{
				scope @trusted void opOpAssign(string op : "~")(scope const(char)[] input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope const(wchar)[] input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope const(dchar)[] input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope String_ASCII input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope String_UTF8 input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope String_UTF16 input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope String_UTF32 input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope StringBuilder_ASCII input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) return
				{
					this.append(input);
				}
				scope @trusted void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) return
				{
					this.append(input);
				}
				scope typeof(this) opBinary(string op : "~")(scope const(char)[] input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope const(wchar)[] input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope const(dchar)[] input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope String_ASCII input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope String_UTF8 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope String_UTF16 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope String_UTF32 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope StringBuilder_ASCII input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF8 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF16 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF32 input)
				{
					typeof(this) ret = this.dup;
					ret.append(input);
					return ret;
				}
				scope @trusted typeof(this) append(scope const(char)[] input...) return;
				scope @trusted typeof(this) append(scope const(wchar)[] input...) return;
				scope @trusted typeof(this) append(scope const(dchar)[] input...) return;
				scope @trusted typeof(this) append(scope String_ASCII input) return;
				scope @trusted typeof(this) append(scope String_UTF8 input) return;
				scope @trusted typeof(this) append(scope String_UTF16 input) return;
				scope @trusted typeof(this) append(scope String_UTF32 input) return;
				scope @trusted typeof(this) append(scope StringBuilder_ASCII input) return;
				scope @trusted typeof(this) append(scope StringBuilder_UTF8 input) return;
				scope @trusted typeof(this) append(scope StringBuilder_UTF16 input) return;
				scope @trusted typeof(this) append(scope StringBuilder_UTF32 input) return;
			}
			@nogc
			{
				scope typeof(this) clobberInsert(ptrdiff_t index, scope const(char)[] input...) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope const(wchar)[] input...) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope const(dchar)[] input...) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope String_ASCII input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF8 input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF16 input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF32 input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_ASCII input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF8 input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF16 input) return;
				scope typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF32 input) return;
			}
			@nogc
			{
				scope size_t replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
				scope size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true, bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown);
			}
			const @nogc scope @trusted ulong toHash();
			package(sidero.base.text.unicode)
			{
				StateIterator state;
				@nogc scope int foreachContiguous(scope int delegate(ref scope Char[] data) nothrow @nogc @safe del, scope void delegate(size_t length) nothrow @nogc @safe lengthDel = null);
			}
		}
	}
}
