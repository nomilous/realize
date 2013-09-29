module.exports = ({errno, code, message, detail}) -> 

    error        = new Error message
    error.errno  = errno
    error.code   = code
    error.detail = detail
    return error
