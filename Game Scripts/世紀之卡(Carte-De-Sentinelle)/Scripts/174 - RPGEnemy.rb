class RPG::Enemy
  def mhp ; @params[0] ; end
  def atk ; @params[2] ; end
  def def ; @params[3] ; end
  def hp ; self.mhp ; end
end

