###############################################################################
# TASK: deploy
#
# shortcut to deploy jekyll site using the production environment
###############################################################################

desc 'Build site with production env'
task :deploy do
  ENV['JEKYLL_ENV'] = 'production'
  system('bundle', 'exec', 'jekyll', 'build')
end
