class Cashu
  def self.generate_token(amount)
    token_str = "#{CASHU_CONFIG[:merchant_id]}:#{amount.to_i.to_s}:#{CASHU_CONFIG[:currency]}:#{CASHU_CONFIG[:encryption_keyword]}"
    return Digest::MD5::hexdigest(token_str)
  end
  
  def self.generate_verification_string(trans_id)
    verification_string = "#{CASHU_CONFIG[:merchant_id]}:#{trans_id}:#{CASHU_CONFIG[:encryption_keyword]}"
    return Digest::SHA1.hexdigest(verification_string)
  end
end