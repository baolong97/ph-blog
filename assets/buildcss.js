const postCssPlugin = require('esbuild-style-plugin')

require('esbuild')
    .build({
        entryPoints: ['css/app.css'],
        bundle: true,
        minify: true,
        logLevel: "info",
        target: "es2017",
        outdir: "../priv/static/assets",
        external: ["*.css", "fonts/*", "images/*"],
        plugins: [
            postCssPlugin({
                postcss: {
                    plugins: [require('tailwindcss'), require('autoprefixer')],
                },
            }),
        ],
    })
    .catch(() => {
        console.error(`Build error: ${error}`)
        process.exit(1)
    })