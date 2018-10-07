# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ar-deltas}
  s.version = "0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Arya Asemanfar"]
  s.date = %q{2009-09-30}
  s.description = %q{ActiveRecord extension to allow for updating numerical attributes using deltas.}
  s.email = %q{aryaasemanfar@gmail.com}
  s.extra_rdoc_files = ["lib/ar-deltas.rb"]
  s.files = ["lib/ar-deltas.rb", "MIT-LICENSE", "Rakefile", "Manifest", "ar-deltas.gemspec", "test/deltas_test.rb", "test/test_helper.rb"]
  s.homepage = %q{https://github.com/arya/ar-deltas/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ar-deltas", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ar-deltas}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{ActiveRecord extension to allow for updating numerical attributes using deltas.}
  s.test_files = ["test/deltas_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
