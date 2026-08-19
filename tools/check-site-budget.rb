# frozen_string_literal: true

site_dir = File.expand_path(ARGV.fetch(0, "_site"))
warning_limit = Integer(ENV.fetch("SITE_SIZE_WARNING_MIB", "900")) * 1024 * 1024
failure_limit = Integer(ENV.fetch("SITE_SIZE_LIMIT_MIB", "930")) * 1024 * 1024

abort "site directory does not exist: #{site_dir}" unless Dir.exist?(site_dir)
abort "SITE_SIZE_WARNING_MIB must be below SITE_SIZE_LIMIT_MIB" unless warning_limit < failure_limit

files = Dir.glob(File.join(site_dir, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }
total_bytes = files.sum { |path| File.size(path) }
megabytes = total_bytes.fdiv(1024 * 1024)
limit_megabytes = failure_limit.fdiv(1024 * 1024)
usage = total_bytes.fdiv(failure_limit) * 100

groups = files.group_by do |path|
  relative = path.delete_prefix("#{site_dir}#{File::SEPARATOR}")
  parts = relative.split(/[\\\/]/)
  parts.first(2).join("/")
end

puts format("Generated site: %.2f MiB across %d files (%.1f%% of %.0f MiB budget)", megabytes, files.size, usage, limit_megabytes)
puts "Largest generated paths:"
groups
  .map { |name, paths| [name, paths.sum { |path| File.size(path) }] }
  .sort_by { |_, bytes| -bytes }
  .first(10)
  .each { |name, bytes| puts format("  %-40s %8.2f MiB", name, bytes.fdiv(1024 * 1024)) }

if total_bytes >= failure_limit
  abort format("Generated site exceeds the %.0f MiB deployment budget", limit_megabytes)
end

if total_bytes >= warning_limit
  warn format("WARNING: generated site exceeds %.0f MiB; move large course assets off GitHub Pages", warning_limit.fdiv(1024 * 1024))
end