module.exports = function(grunt){
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.initConfig({
        coffee:{
            compileJoined: {
                options: {
                    join: true
                },
                files: {
                    'js/main.js': 'coffee/*.coffee' // concat then compile into single file
                }
            },
        }
    });
    grunt.registerTask('default',[
        'coffee'
    ]);
}
