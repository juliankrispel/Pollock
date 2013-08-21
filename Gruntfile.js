module.exports = function(grunt){
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.initConfig({
        coffee:{
            compileJoined: {
                options: {
                    join: true
                },
                files: {
                    'js/painter.js': [
                        'coffee/util.coffee', 
                        'coffee/painter.coffee',
                        'coffee/renderer.coffee',
                        'coffee/loop.coffee',
                    ],
                    'js/ui.js': [
                        'coffee/ui.coffee'
                    ],
                    'js/mtest.js': [
                        'coffee/mutable.coffee'
                    ]
                }
            },
        },
        watch: {
            coffee: {
                files: ['coffee/*.coffee', 'example/coffee/*.coffee'],
                tasks: 'coffee'
            }
        }
    });
    grunt.registerTask('default',[
        'coffee', 'watch'
    ]);
}
