module.exports = (errno, code, message) -> 

    error       = new Error message
    error.errno = errno
    error.code  = code
    return error
