class BadwordsController < ApplicationController
  # GET /badwords
  # GET /badwords.xml
  def index
    @badwords = Badword.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @badwords }
    end
  end

  # GET /badwords/1
  # GET /badwords/1.xml
  def show
    @badword = Badword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @badword }
    end
  end

  # GET /badwords/new
  # GET /badwords/new.xml
  def new
    @badword = Badword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @badword }
    end
  end

  # GET /badwords/1/edit
  def edit
    @badword = Badword.find(params[:id])
  end

  # POST /badwords
  # POST /badwords.xml
  def create
    @badword = Badword.new(params[:badword])

    respond_to do |format|
      if @badword.save
        flash[:notice] = 'Badword was successfully created.'
        format.html { redirect_to(@badword) }
        format.xml  { render :xml => @badword, :status => :created, :location => @badword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @badword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /badwords/1
  # PUT /badwords/1.xml
  def update
    @badword = Badword.find(params[:id])

    respond_to do |format|
      if @badword.update_attributes(params[:badword])
        flash[:notice] = 'Badword was successfully updated.'
        format.html { redirect_to(@badword) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @badword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /badwords/1
  # DELETE /badwords/1.xml
  def destroy
    @badword = Badword.find(params[:id])
    @badword.destroy

    respond_to do |format|
      format.html { redirect_to(badwords_url) }
      format.xml  { head :ok }
    end
  end
end
