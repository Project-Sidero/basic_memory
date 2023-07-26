module utilities.sequential_ranges;
import std.traits : isNumeric, isSomeChar;

@safe:

struct ValueRange(KeyType = dchar) if (isNumeric!KeyType || isSomeChar!KeyType) {
    KeyType start, end;
@safe:

    this(KeyType index) {
        this.start = index;
        this.end = index;
    }

    this(KeyType start, KeyType end) {
        assert(end >= start);

        this.start = start;
        this.end = end;
    }

    bool isSingle() {
        return start == end;
    }

    bool within(KeyType index) {
        return start <= index && end >= index;
    }
}

struct SequentialRangeSplitGroup {
}

struct SequentialRanges(MetaDataEntry, MetaDataGroup = SequentialRangeSplitGroup, size_t NumberOfLayers = 0, KeyType = dchar)
        if (isNumeric!KeyType || isSomeChar!KeyType) {
    private Datem* datems;

    void add(KeyType index, MetaDataEntry metadataEntry) {
        Datem** parent = &datems;
        Datem* datem = datems;

        while(datem !is null && datem.range.start <= index) {
            if(datem.range.within(index)) {
                datem.metadataEntries[index - datem.range.start] = metadataEntry;

                sanityCheck(index);
                return;
            } else if(datem.range.end + 1 == index && (datem.next is null || datem.next.range.start > index)) {
                datem.range.end = index;
                datem.metadataEntries ~= metadataEntry;

                if(datems.next !is null && datems.next.range.start == index + 1) {
                    datem.range.end = datem.next.range.end;
                    datem.metadataEntries ~= datem.next.metadataEntries;
                    datem.next = datem.next.next;
                }

                sanityCheck(index);
                return;
            } else if(datem.range.start == index + 1) {
                datem.range.start = index;
                datem.metadataEntries = [metadataEntry] ~ datem.metadataEntries;

                sanityCheck(index);
                return;
            }

            parent = &datem.next;
            datem = datem.next;
        }

        *parent = new Datem(datem, ValueRange!KeyType(index), [metadataEntry]);
        sanityCheck(index);
    }

    void splitFor(scope void delegate(Datem datem, out size_t splitForOffset, out size_t splitForLength,
            out MetaDataGroup[2] groupMetaData, out bool[2] allTheSame) @safe del) {

        scope(exit)
            sanityCheck;

        size_t splitForOffset, splitForLength;
        MetaDataGroup[2] groupMetaData;
        bool[2] allTheSame;

        Datem* datem = datems;
        while(datem !is null) {
            del(*datem, splitForOffset, splitForLength, groupMetaData, allTheSame);
            assert(splitForLength == 0 || splitForOffset > 0);

            if(splitForLength == 0) {
                datem = datem.next;
            } else if(splitForOffset + splitForLength < (datem.range.end + 1) - datem.range.start) {
                assert(splitForOffset + splitForLength <= (datem.range.end + 1) - datem.range.start);
                Datem* middle = new Datem(null, ValueRange!KeyType(cast(KeyType)(datem.range.start + splitForOffset),
                        cast(KeyType)(datem.range.start + splitForOffset + splitForLength - 1)),
                        datem.metadataEntries[splitForOffset .. splitForOffset + splitForLength], groupMetaData[1]);
                Datem* end = new Datem(null,
                        ValueRange!KeyType(cast(KeyType)(datem.range.start + splitForOffset + splitForLength), datem.range.end),
                        datem.metadataEntries[splitForOffset + splitForLength .. $]);

                middle.next = end;
                middle.allTheSame = allTheSame[1];
                end.next = datem.next;

                datem.next = middle;
                datem.metadataGroup = groupMetaData[0];
                datem.allTheSame = allTheSame[0];

                datem.range.end = cast(KeyType)(datem.range.start + splitForOffset - 1);
                datem.metadataEntries = datem.metadataEntries[0 .. splitForOffset];

                datem = end;
            } else {
                assert(splitForOffset + splitForLength <= (datem.range.end + 1) - datem.range.start);
                Datem* middle = new Datem(null, ValueRange!KeyType(cast(KeyType)(datem.range.start + splitForOffset),
                        datem.range.end), datem.metadataEntries[splitForOffset .. splitForOffset + splitForLength], groupMetaData[1]);

                middle.next = datem.next;
                middle.allTheSame = allTheSame[1];
                datem.next = middle;
                datem.metadataGroup = groupMetaData[0];
                datem.allTheSame = allTheSame[0];

                datem.range.end = cast(KeyType)(datem.range.start + splitForOffset - 1);
                datem.metadataEntries = datem.metadataEntries[0 .. splitForOffset];
                datem = middle;
            }
        }
    }

    void calculateTrueSpread() {
        Datem* datem = datems;

        while(datem !is null) {
            datem.spread = (datem.range.end + 1) - datem.range.start;

            datem.allTheSame = true;
            foreach(metadataEntry; datem.metadataEntries[1 .. $]) {
                if(metadataEntry != datem.metadataEntries[0]) {
                    datem.allTheSame = false;
                    break;
                }
            }

            datem = datem.next;
        }
    }

    /// Requires true spread to be calculated.
    void joinFor(scope bool delegate(Datem first, Datem second) @safe del,
            MetaDataEntry delegate(KeyType) @safe defaultEntryDel = null, MetaDataGroup defaultGroup = MetaDataGroup.init) {

        scope(exit)
            sanityCheck;

        Datem* datem = datems;

        while(datem !is null && datem.next !is null) {
            assert(datem.spread != 0);
            assert(datem.next.spread != 0);
            assert(datem.next.range.start > datem.range.end);

            bool join = del(*datem, *datem.next);

            KeyType diffReal = datem.next.range.start - (datem.range.end + 1);
            if(diffReal > size_t.max)
                join = false;

            if(join) {
                size_t diff = cast(size_t)diffReal;
                size_t offsetOfExtended = datem.metadataEntries.length;

                MetaDataEntry[] newEntries = new MetaDataEntry[offsetOfExtended + diff + datem.next.metadataEntries.length];
                newEntries[0 .. offsetOfExtended][] = datem.metadataEntries[];
                newEntries[offsetOfExtended + diff .. $][] = datem.next.metadataEntries[];

                if(defaultEntryDel is null)
                    newEntries[offsetOfExtended .. offsetOfExtended + diff][] = MetaDataEntry.init;
                else {
                    foreach(i, ref v; newEntries[offsetOfExtended .. offsetOfExtended + diff]) {
                        v = defaultEntryDel(cast(KeyType)(datem.range.start + i + offsetOfExtended));
                    }
                }

                datem.allTheSame = datem.allTheSame && datem.next.allTheSame && newEntries[0] == newEntries[offsetOfExtended + diff];

                datem.metadataEntries = newEntries;
                datem.metadataGroup = defaultGroup;

                datem.spread += datem.next.spread;
                assert(datem.next.range.start > datem.range.end);
                datem.range.end = datem.next.range.end;
                datem.next = datem.next.next;
                assert(datem.range.start <= datem.range.end);
                assert(datem.next is null || datem.next.range.start > datem.range.end);
            } else
                datem = datem.next;
        }
    }

    void layerBy(scope bool delegate(Datem firstOfLayer, Datem proposed, size_t layer) @safe del, size_t layer,
            MetaDataEntry delegate(KeyType) @safe defaultEntryDel = null, MetaDataGroup defaultGroup = MetaDataGroup.init) {
        assert(layer < NumberOfLayers);

        scope(exit)
            sanityCheck;

        Datem* firstOnLayer = datems;

        while(firstOnLayer !is null) {
            if(firstOnLayer.nextOnLayer[layer] is null) {
                firstOnLayer.rangeOnLayer[layer] = firstOnLayer.range;
                firstOnLayer.spreadOnLayer[layer] = firstOnLayer.spread;
            }

        OnMergeWhenOnLayer:
            Datem* lastInLayer = firstOnLayer;
            Datem** parentOfNextInLayer = &firstOnLayer.nextOnLayer[layer];

            while(*parentOfNextInLayer !is null) {
                lastInLayer = *parentOfNextInLayer;
                parentOfNextInLayer = &(*parentOfNextInLayer).nextOnLayer[layer];
            }

            for(;;) {
                Datem* proposed = lastInLayer.next;

                if(proposed is null || !del(*firstOnLayer, *proposed, layer))
                    break;

                *parentOfNextInLayer = proposed;

                if(proposed.nextOnLayer[layer]!is null) {
                    firstOnLayer.spreadOnLayer[layer] += proposed.spreadOnLayer[layer];
                    firstOnLayer.rangeOnLayer[layer].end = proposed.rangeOnLayer[layer].end;
                    goto OnMergeWhenOnLayer;
                } else {
                    firstOnLayer.spreadOnLayer[layer] += proposed.spread;
                    firstOnLayer.rangeOnLayer[layer].end = proposed.range.end;
                }

                parentOfNextInLayer = &proposed.nextOnLayer[layer];
                lastInLayer = proposed;
            }

            if(lastInLayer is null)
                firstOnLayer = firstOnLayer.next;
            else {
                firstOnLayer = lastInLayer.next;
            }
        }
    }

    int opApply(scope int delegate(Datem datem, size_t[NumberOfLayers] layerIndex) @safe del) {
        int result;

        Datem* datem = datems;
        size_t[NumberOfLayers] indexes;
        bool[NumberOfLayers] lastNull;

        while(datem !is null) {
            result = del(*datem, indexes);
            if(result)
                return result;

            foreach(i; 0 .. NumberOfLayers)
                lastNull[i] = datem.nextOnLayer[i] is null;

            datem = datem.next;

            foreach_reverse(i; 0 .. NumberOfLayers) {
                if(lastNull[i]) {
                    indexes[0 .. i + 1] = 0;
                    break;
                } else
                    indexes[i]++;
            }
        }

        return result;
    }

    string toString() {
        import std.array : appender;
        import std.format : formattedWrite;

        auto temp = appender!string();

        foreach(datem, layerIndexes; this) {
            foreach_reverse(index; layerIndexes)
                temp ~= index == 0 ? "." : "|";
            if(NumberOfLayers > 0)
                temp ~= "  ";
            temp.formattedWrite!"--- %s\n"(layerIndexes);

            foreach(c, metadata; datem) {
                foreach_reverse(index; layerIndexes)
                    temp ~= "|";
                if(NumberOfLayers > 0)
                    temp ~= "    ";

                temp.formattedWrite!"%s: %s\n"(c, metadata);
            }
        }

        return temp.data.dup;
    }

    version(none) {
        void debugMe() {
            Datem* datem = datems;

            import std.stdio;

            writeln("--------");

            while(datem !is null) {
                static if(is(KeyType == ulong)) {
                    if(datem.range.within(0x30700000044)) {
                        writefln!"0x%X <= input <= 0x%X"(datem.range.start, datem.range.end);
                        writefln!"%X"(datem.metadataEntries[0x30700000044 - datem.range.start]);
                        foreach(entry; datem.metadataEntries)
                            writef!"%X, "(entry);
                        writeln;
                    }
                }
                datem = datem.next;
            }
        }
    }

    struct Datem {
        Datem* next;
        ValueRange!KeyType range;
        MetaDataEntry[] metadataEntries;
        MetaDataGroup metadataGroup;
        size_t spread;
        bool allTheSame;

        Datem*[NumberOfLayers] nextOnLayer;
        ValueRange!KeyType[NumberOfLayers] rangeOnLayer;
        size_t[NumberOfLayers] spreadOnLayer;

        int opApply(scope int delegate(KeyType, ref MetaDataEntry) @safe del) {
            int result;

            foreach(KeyType index; range.start .. range.end + 1) {
                result = del(index, metadataEntries[index - range.start]);
                if(result)
                    return result;
            }

            return result;
        }
    }

private:
    void sanityCheck(KeyType index = KeyType.init) {
        debug {
            import std.stdio : writeln, stdout;

            Datem* datem = datems;
            if(datem is null)
                return;

            KeyType lastEnd = datem.range.end;
            datem = datem.next;

            while(datem !is null) {
                if(lastEnd >= datem.range.start) {
                    writeln("Key ", index, " results in ", lastEnd, " and ", datem.range.start, " to equal.");
                    stdout.flush;
                    assert(0);
                }

                lastEnd = datem.range.end;
                datem = datem.next;
            }
        }
    }
}

void splitForSame(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers, KeyType) sr, size_t minimum = 8) {

    sr.splitFor((sr.Datem datem, out size_t splitForOffset, out size_t splitForLength,
            out MetaDataGroup[2] groupMetaData, out bool[2] allTheSame) {
        allTheSame[0] = datem.allTheSame;

        size_t toSkip;
        foreach(offset; 0 .. (datem.range.end + 1) - datem.range.start) {
            size_t same = 1;

            foreach(metadata; datem.metadataEntries[offset + 1 .. $]) {
                if(metadata != datem.metadataEntries[offset])
                    break;
                same++;
            }

            toSkip = same;
            if(same > 1)
                break;
        }

        foreach(offset; toSkip .. (datem.range.end + 1) - datem.range.start) {
            size_t same = 1;

            foreach(metadata; datem.metadataEntries[offset + 1 .. $]) {
                if(metadata != datem.metadataEntries[offset])
                    break;
                same++;
            }

            if(same >= minimum) {
                splitForOffset = offset;
                splitForLength = same;
                allTheSame[1] = true;
                return;
            }
        }
    });
}

void joinWhenClose(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers,
        KeyType) sr, MetaDataEntry delegate(KeyType) @safe defaultEntryDel = null,
        KeyType ratioMultiplierBetweenFirst = 5, KeyType limiter = 1024) {

    sr.joinFor((sr.Datem first, sr.Datem second) {
        bool join = first.allTheSame == second.allTheSame;
        if(join && first.allTheSame)
            join = first.metadataEntries[0] == second.metadataEntries[0];

        size_t diffBetweenFirstAndSecond = second.range.start - (first.range.end + 1);
        bool join2 = diffBetweenFirstAndSecond < ratioMultiplierBetweenFirst ||
            (diffBetweenFirstAndSecond * ratioMultiplierBetweenFirst) <= (first.range.end - first.range.start);
        bool join3 = diffBetweenFirstAndSecond < limiter;

        return join && join2 && join3;
    }, defaultEntryDel);
}

void joinWithDiff(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers, KeyType) sr, MetaDataEntry delegate(KeyType) @safe defaultEntryDel = null, KeyType limiter = 16) {

    sr.joinFor((sr.Datem first, sr.Datem second) {
        assert(second.range.start > first.range.end);
        auto diffBetweenFirstAndSecond = second.range.start - (first.range.end + 1);
        return diffBetweenFirstAndSecond < limiter;
    }, defaultEntryDel);
}

void layerByRangeMax(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers, KeyType) sr, size_t layer, ulong maximum = ushort.max) {

    sr.layerBy((firstOfLayer, proposed, size_t layer) {
        auto planeStartFirst = cast(ulong)firstOfLayer.range.start - (firstOfLayer.range.start % maximum),
            planeStartSecond = cast(ulong)proposed.range.start - (proposed.range.start % maximum);
        auto planeEndFirst = cast(ulong)firstOfLayer.range.end - (firstOfLayer.range.end % maximum),
            planeEndSecond = cast(ulong)proposed.range.end - (proposed.range.end % maximum);
        bool isAllInSame = (planeEndSecond - planeStartFirst) <= maximum;

        return isAllInSame;
    }, layer);
}

void layerBySingleMulti(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers, KeyType) sr, size_t layer) {
    sr.layerBy((firstOfLayer, proposed, size_t layer) { return firstOfLayer.range.isSingle && proposed.range.isSingle; }, layer);
}

void layerJoinIfEndIsStart(MetaDataEntry, MetaDataGroup, size_t NumberOfLayers, KeyType)(SequentialRanges!(MetaDataEntry,
        MetaDataGroup, NumberOfLayers, KeyType) sr, size_t layer, size_t diffMax = 1) {

    sr.layerBy((firstOfLayer, proposed, size_t layer) {
        return proposed.range.start <= firstOfLayer.rangeOnLayer[layer].end + diffMax;
    }, layer);
}
