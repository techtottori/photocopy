class UsersController < ApplicationController
  before_action :authorize, except: [:sign_up, :sign_up_process, :sign_in, :sign_in_process]
  before_action :redirect_to_top_if_signed_in, only: [:sign_up, :sign_in]
  def top
    if params[:word].present?
      @posts = Post.where("caption like ?", "%#{params[:word]}%").order("id desc")
    else
      @posts = Post.all.order("id desc")
    end
    
    @recommends = User.where.not(id: current_user.id).where.not(id: current_user.follows.pluck(:follow_user_id)).limit(3)
  end
  
  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id)
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
  def update
    @user = User.new(user_params)
    upload_file = params[:user][:image]
    if upload_file.present?
      upload_file_name = upload_file.original_filename
      output_dir = Rails.root.join('public', 'users')
      output_path = output_dir + upload_file_name
      File.open(output_path, 'w+b') do |f|
        f.write(upload_file.read)
      end
    current_user.update(user_params.merge({image: upload_file.original_filename}))
    flash[:danger] = "プロフィールを編集しました。"
    redirect_to('/top')
    end
  end
  
  def follow
    @user = User.find(params[:id])
    if Follow.exists?(user_id: current_user.id, follow_user_id: @user.id)
      Follow.find_by(user_id: current_user.id, follow_user_id: @user.id).destroy
    else
      Follow.create(user_id: current_user.id, follow_user_id: @user.id)
    end
    redirect_back(fallback_location: top_path, notice: "フォローを更新しました。")
  end
  
  def follow_list
    @user = User.find(params[:id])
    @users = User.where(id: Follow.where(user_id: @user.id).pluck(:follow_user_id))
  end
  
  def follower_list
    @user = User.find(params[:id])
    @users = User.where(id: Follow.where(user_id: @user.id).pluck(:follow_user_id))
  end
  
  def sign_up
    @user = User.new
    render layout: "application_not_login"
  end
  
  def sign_in
    @user = User.new
    render layout: "application_not_login"
  end
  
  def sign_up_process
    user = User.new(user_params)
    if user.save
      user_sign_in(user)
      redirect_to('/')
    else
      # 登録が失敗したらユーザー登録ページへ
      flash[:danger] = "ユーザー登録に失敗しました。"
      redirect_to('/sign_up')
    end
  end
  
  def sign_in_process
    password_md5 = User.generate_password(user_params[:password])
    user = User.find_by(email: user_params[:email], password: password_md5)
    if user
    user_sign_in(user)
    redirect_to top_path and return
    else
      flash[:danger] = "サインインに失敗しました。"
      redirect_to('/sign_in')
    end
  end
  
  def sign_out
    user_sign_out
    redirect_to sign_in_path and return
  end
  
  def authorize
    redirect_to sign_in_path unless user_signed_in?
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :comment)
  end
end