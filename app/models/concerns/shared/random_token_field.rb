module Shared::RandomTokenField
  as_trait do |*fields|
    fields.each do |field|

      define_method("generate_#{field}_token") do
        token = RandomToken.generate
        self.send("#{field}_token=".to_sym, RandomToken.digest(token))
        self.send("#{field}_token_date=".to_sym, DateTime.now)
        token
      end

      define_method("#{field}_token_matches?") do |token|
        self.send("#{field}_token".to_sym) == RandomToken.digest(token)
      end

    end
  end
end