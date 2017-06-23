module.exports = config => {
    config.set({
        autoWatch: true,
        browsers: ["Chrome"],
        files: [
            "dist/karma/index.js",
        ],
        frameworks: [
            "mocha",
        ],
        plugins: [
            "karma-chrome-launcher",
            "karma-firefox-launcher",
            "karma-spec-reporter",
            "karma-mocha",
        ],
        reporters: ["spec"],
        singleRun: false,
        client: {
            mocha: {
                timeout: 10000
            }
        }
    });
};
