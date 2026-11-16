class Module
  def attr_sec_accessor(sym, default = 0)
    attr_writer sym
    attr_sec_reader sym, default
  end
  
  def attr_sec_reader(sym, default = 0)
    sym = sym.id2name
    string = "def #{sym} ;" +
             "  @#{sym} = #{default}  if @#{sym}.nil? ;" +
             "  @#{sym} ;" +
             "end ;"
    module_eval(string)
  end
end