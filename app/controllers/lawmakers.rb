class Lawmakers < Application

  def index
    render
  end

  def get id
    @lawmaker = Lawmaker.get(id)
    display @lawmaker
  end
  
end
