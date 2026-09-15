slow_test = "test_created_product_is_available_after_five_seconds"

case ARGV.shift
when nil
  ARGV.concat(["--exclude", slow_test])
when "--slow"
  ARGV.concat(["--name", slow_test])
when "--all"
else
  abort "Usage: ruby test/run.rb [--all|--slow]"
end

Dir["test/**/*_test.rb"].sort.each do |file|
  require File.expand_path(file)
end
