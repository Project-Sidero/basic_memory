module sidero.base.internal.posix;
import core.stdc.stdio;

version(Posix) {
    import core.sys.posix.sys.types;
} else {
    alias ssize_t = size_t;
    alias off_t = ulong;
}

export nothrow @nogc:

/**
Apply any socket options required for the write abstraction here.

Returns: if it succeded in applying the required options.
*/
void applyPerSocketFlag(FILE* socket) {
    applyPerSocketFlag(fileno(socket));
}

/// Ditto
bool applyPerSocketFlag(int s) {
    version(Posix) {
        import core.sys.posix.sys.socket;

        static if(__traits(compiles, SO_NOSIGPIPE)) {
            int enable = 1;
            if (setsockopt(s, SOL_SOCKET, SO_NOSIGPIPE, &enable, int.sizeof) != 0)
                return false;
        }
    }

    return true;
}

/**
Write to a socket, handling SIGPIPE error via blocking and consuming the signal.

If a pending SIGPIPE is queued due to blocking, it will not be consumed, and should be left unaffected (max should be one queued).

May call ``writeAppend``, instead.

You must call ``applyPerSocketFlag`` prior to calling this.
*/
ssize_t writeOnSocket(FILE* socket, const scope void* buffer, size_t length, int flags = 0) {
    return writeOnSocket(fileno(socket), buffer, length, flags);
}

/// Ditto
ssize_t writeOnSocket(int socket, const scope void* buffer, size_t length, int flags = 0) {
    version(Posix) {
        import core.sys.posix.sys.socket;

        static if(__traits(compiles, SO_NOSIGPIPE)) {
            return send(socket, buffer, length, flags);
        } else static if(__traits(compiles, MSG_NOSIGNAL)) {
            return send(socket, buffer, length, flags | MSG_NOSIGNAL);
        } else {
            return writeAppend(socket, buffer, length);
        }
    } else
        assert(0, "Unimplemented, use platform specific functions for writing on a socket");
}

/**
Write to a file, handling SIGPIPE error via blocking and consuming the signal.

If a pending SIGPIPE is queued due to blocking, it will not be consumed, and should be left unaffected (max should be one queued).
*/
ssize_t writeAppend(FILE* file, const scope void* buffer, size_t length) {
    return writeAppend(fileno(file), buffer, length);
}

/// Ditto
ssize_t writeAppend(int file, const scope void* buffer, size_t length) {
    version(Posix) {
        import core.sys.posix.signal;
        import core.sys.posix.unistd;
        import core.sys.posix.time;
        import core.stdc.errno;

        sigset_t block, old, pending;

        sigemptyset(&block);
        sigaddset(&block, SIGPIPE);

        if(pthread_sigmask(SIG_BLOCK, &block, &old) != 0)
            return -1;

        int pendingtype = -1;
        if(sigpending(&block) != -1)
            pendingtype = sigismember(&pending, SIGPIPE);

        ssize_t ret;
        while((ret = write(file, buffer, length)) == -1 && errno == EINTR) {
        }

        if(ret == -1 && errno == EPIPE && pendingtype == 0) {
            static if(__traits(compiles, sigtimedwait)) {
                timespec ts;
                int sig;

                while((sig = sigtimedwait(&block, null, &ts)) == -1 && errno == EINTR) {
                }
            } else {
                pendingtype = -1;
                if(sigpending(&block) != -1)
                    pendingtype = sigismember(&pending, SIGPIPE);
                if(pendingtype == 1)
                    sigwait(&block, null);
            }
        }

        pthread_sigmask(SIG_SETMASK, &old, null);
        return ret;
    } else
        assert(0, "Unimplemented, use platform specific functions for writing to a fd");
}

/**
Write to a file at offset, handling SIGPIPE error via blocking and consuming the signal.

If a pending SIGPIPE is queued due to blocking, it will not be consumed, and should be left unaffected (max should be one queued).
*/
ssize_t writeToOffset(FILE* file, const scope void* buffer, size_t length, off_t offset) {
    return writeToOffset(fileno(file), buffer, length, offset);
}

/// Ditto
ssize_t writeToOffset(int file, const scope void* buffer, size_t length, off_t offset) {
    version(Posix) {
        import core.sys.posix.signal;
        import core.sys.posix.unistd;
        import core.sys.posix.time;
        import core.stdc.errno;

        sigset_t block, old, pending;

        sigemptyset(&block);
        sigaddset(&block, SIGPIPE);

        if(pthread_sigmask(SIG_BLOCK, &block, &old) != 0)
            return -1;

        int pendingtype = -1;
        if(sigpending(&block) != -1)
            pendingtype = sigismember(&pending, SIGPIPE);

        ssize_t ret;
        while((ret = pwrite(file, buffer, length, offset)) == -1 && errno == EINTR) {
        }

        if(ret == -1 && errno == EPIPE && pendingtype == 0) {
            static if(__traits(compiles, sigtimedwait)) {
                timespec ts;
                int sig;

                while((sig = sigtimedwait(&block, null, &ts)) == -1 && errno == EINTR) {
                }
            } else {
                pendingtype = -1;
                if(sigpending(&block) != -1)
                    pendingtype = sigismember(&pending, SIGPIPE);
                if(pendingtype == 1)
                    sigwait(&block, null);
            }
        }

        pthread_sigmask(SIG_SETMASK, &old, null);
        return ret;
    } else
        assert(0, "Unimplemented, use platform specific functions for writing to a fd");
}
