# frozen_string_literal: true

source "https://mirrors.tuna.tsinghua.edu.cn/rubygems"

gemspec

gem "html-proofer", "~> 5.0", group: :test

platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.2.0", :platforms => [:windows]
