class Lawmakers < Application

  def index
    render
  end

  def show id
    @lawmaker = Lawmaker.get(id)
    display @lawmaker
  end
  
end
