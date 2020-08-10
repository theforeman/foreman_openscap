const tfmConfig = require('@theforeman/test/src/pluginConfig');

tfmConfig.transform["^.+\\.svg$"] = "jest-svg-transformer";

module.exports = tfmConfig;
