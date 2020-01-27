require "./specification"

module Molinillo
  FIXTURE_INDEX_DIR = FIXTURE_DIR / "index"

  class TestIndex
    getter specs : Hash(String, Array(TestSpecification))
    include SpecificationProvider(Gem::Dependency | TestSpecification, TestSpecification)

    def self.from_fixture(fixture_name)
      new(TestIndex.specs_from_fixture(fixture_name))
    end

    @@specs_from_fixture = {} of String => Hash(String, Array(TestSpecification))

    def self.specs_from_fixture(fixture_name)
      @@specs_from_fixture[fixture_name] ||= begin
        lines = File.read_lines(FIXTURE_INDEX_DIR / (fixture_name + ".json"))
        lines = lines.map { |line| line.partition("//")[0] }
        Hash(String, Array(TestSpecification)).from_json(lines.join '\n').tap do |all_specs|
          all_specs.each do |name, specs|
            specs.sort! { |a, b| Shards::Versions.compare(b.version, a.version) }
          end
        end
        # JSON.load(fixture).reduce(Hash.new([])) do |specs_by_name, (name, versions)|
        #   specs_by_name.tap do |specs|
        #     specs[name] = versions.map { |s| TestSpecification.new s }.sort_by(&:version)
        #   end
        # end


      end
    end

    def initialize(@specs)
    end

    def search_for(dependency : R)
      case dependency
      when Gem::Dependency
        specs[dependency.name].select do |spec|
          dependency.requirement.satisfied_by?(spec.version)
        end
      else
        raise "BUG: Unexpected dependency type: #{dependency}"
      end
    end

    def dependencies_for(specification : S)
      specification.dependencies
      # raise "tbd: dependencies_for #{specification.inspect}"
    end
  end
end