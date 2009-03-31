class Lawmakers < Application

  def index
    render
  end

  def show id
    @lawmaker = Lawmaker.get(id)
    @tweets   = @lawmaker.tweets(:order => [:id.desc], :limit => 15)
    display @lawmaker
  end
  
end
