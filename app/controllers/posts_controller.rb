class PostsController < ApplicationController
  before_action :authorize
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    upload_file = params[:post][:upload_file]
    if upload_file.blank?
      flash[:danger] = "投稿には画像が必須です。"
      redirect_to new_post_path and return
    end
    upload_file_name = upload_file.original_filename
    output_dir = Rails.root.join('public', 'images')
    output_path = output_dir + upload_file_name
    File.open(output_path, 'w+b') do |f|
      f.write(upload_file.read)
    end
    # post_imagesテーブルに登録するファイル名をPostインスタンスに格納
    @post.post_images.new(name: upload_file_name)
    # データベースに保存
    if @post.save
       redirect_to('/')
      flash[:danger] = "投稿に成功しました。"
    else
      flash[:danger] = "保存に失敗しました。"
      redirect_to('/posts/new')
    end
  end
  
  def destroy
    @post = Post.find(params[:id])
    if @post.destroy
      flash[:danger] = "投稿を削除しました。"
      redirect_to('/top')
    else
      flash[:danger] = "削除に失敗しました。"
    end
  end
  
  def like
    @post = Post.find(params[:id])
    if PostLike.exists?(post_id: @post.id, user_id: current_user.id)
      PostLike.find_by(post_id: @post.id, user_id: current_user.id).destroy
    else
      PostLike.create(post_id: @post.id, user_id: current_user.id)
    end
    redirect_to top_path and return
  end
  
  # コメント投稿処理
  def comment
    # 投稿IDを受け取り、投稿データを取得
    @post = Post.find(params[:id])
    
    # コメント保存
    @post.post_comments.create(post_comment_params)
    redirect_to('/')
  end
  
  def authorize
    redirect_to top_path unless user_signed_in?
  end
  
  private
  def post_params
    params.require(:post).permit(:caption).merge(user_id: current_user.id)
  end
  
  def post_comment_params
    params.require(:post_comment).permit(:comment).merge(user_id: current_user.id)
  end
end