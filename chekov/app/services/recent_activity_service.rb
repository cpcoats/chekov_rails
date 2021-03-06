
module RecentActivityService
  extend self

  MAX_TOP_COMMENTERS = 5
  MAX_TOP_REPORTERS = 5
  MAX_TOP_ACTIVITIES = 7

  def for_user(user)
    last_visit = user.last_visited_at - 1.week # - 1.day
    return [] if last_visit.nil?

    @recents = {}

    Task.where('updated_at >= ?', last_visit).each do |task|
      entry = TaskActivityEntry.new(task)
      @recents[entry.timestamp] = entry
    end

    Comment.where('updated_at >= ?', last_visit).each do |comment|
      entry = CommentActivityEntry.new(comment)
      @recents[entry.timestamp] = entry
    end

    @recents.sort.reverse[0...MAX_TOP_ACTIVITIES]
  end

  def top_commenters
    Comment
      .limit(MAX_TOP_COMMENTERS)
      .count(:group => :commenter)
      .map { |user, count| { :name => UserPresenter.new(user), :count  => count } }
      .sort_by { |entry| entry[:count] }
      .reverse
  end

  def top_reporters
    Task
      .limit(MAX_TOP_REPORTERS)
      .count(:group => :reporter)
      .map { |user, count| { :name => UserPresenter.new(user), :count  => count } }
      .sort_by { |entry| entry[:count] }
      .reverse
  end

  private

  class AbstractActivityEntry
    attr_accessor :type, :action, :agent, :timestamp

    def initialize(entry)
      @entry = entry
      @timestamp = @entry.updated_at.to_i
      @is_created = @entry.created_at == @entry.updated_at
    end

    def formatted_time
      @entry.updated_at.strftime('%b %e, %Y %l:%M %p')
    end
  end

  class TaskActivityEntry < AbstractActivityEntry
    @type = "task"

    def agent
      UserPresenter.new(@entry.reporter)
    end

    def action
      @is_created ?
        "created task ##{ @entry.id }" :
        "updated task ##{ @entry.id }"
    end
  end

  class CommentActivityEntry < AbstractActivityEntry
    @type = "comment"

    def agent
      UserPresenter.new(@entry.commenter)
    end

    def action
      @is_created ?
        "commented on task ##{ @entry.task.id }" :
        "updated a comment on task ##{ @entry.task.id }"
    end
  end

end