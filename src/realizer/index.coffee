modules = ['configure', 'connect', 'run', 'error']
exports[mod] = require "./#{mod}" for mod in modules
