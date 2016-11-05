class String
  def sc_encrypt(sc=SecureConf.default)
    sc.encrypt(self)
  end

  def sc_decrypt(sc=SecureConf.default)
    sc.decrypt(self)
  end
end
