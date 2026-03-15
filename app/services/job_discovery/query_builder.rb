module JobDiscovery
  class QueryBuilder
    def self.build
      queries = []

      SearchDomains.list.each do |domain|
        SearchTerms.list.each do |term|
          queries << "site:#{domain} #{term}"
        end
      end

      queries
    end
  end
end