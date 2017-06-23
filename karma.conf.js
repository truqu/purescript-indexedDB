module.exports = config => {
    config.set({
        autoWatch: true,
        browsers: ["Chrome", "Firefox"],
        files: [
            "dist/karma/index.js",
        ],
        plugins: [
            "karma-chrome-launcher",
            "karma-firefox-launcher",
            "karma-spec-reporter"
        ],
        reporters: ["spec"],
        singleRun: true
    });
};
