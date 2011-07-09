class Rmend
  
  def scaledown(prefs, rate=0.1)
    subjects = prefs.keys
    
    puts " "
    p "subjects: #{subjects}"
    puts " "
    
    realdist = {}
    subjects.each do |subject|
      realdist[subject] ||= {}
      scores = subjects.map do |critic|
        r = euclidean(prefs, subject, critic, false)
        puts " "
        p "r: #{r}"
        puts " "
        realdist[subject][critic] = r unless r == 0
      end
    end
    
    puts " "
    p "realdist: #{realdist}"
    puts " "

    locs = {}
    subjects.each do |subject|
      locs[subject] = [rand, rand]
    end
    
    fakedist = {}
    subjects.each do |subject|
      subjects.each do |critic|
        fakedist[subject] ||= {}
        fakedist[subject][critic] = 0.0
      end
    end

    last_error = nil
    
    (0...1000).each do |n|
      
      subjects.each do |subject|
        prefs.each do |critic, objects|
          s_x, s_y = locs[subject]
          c_x, c_y = locs[critic]
          fakedist[subject][critic] = ((s_x - c_x) ** 2) + ((s_y - c_y) ** 2)
        end
      end
      
      grad = {}
      subjects.each do |subject|
        grad[subject] = [0.0, 0.0]
      end
      
      total_error = 0.0
      subjects.each do |subject|
        subjects.each do |critic|
          next unless realdist[subject][critic]
          error_term = (fakedist[subject][critic] - realdist[subject][critic])/realdist[subject][critic]
          
          grad[subject][0] += ((locs[subject][0] - locs[critic][0])/fakedist[subject][critic])*error_term
          grad[subject][1] += ((locs[subject][1] - locs[critic][1])/fakedist[subject][critic])*error_term
          
          total_error += error_term.abs
        end
      end
      
      p "total_error: #{total_error}"
      
      if last_error and last_error < total_error
        break
      else
        last_error = total_error
      end
      
      subjects.each do |subject|
        locs[subject][0] -= rate*grad[subject][0]
        locs[subject][1] -= rate*grad[subject][1]
      end
      
    end
    return locs
  end
  
  def simple(subjects_ratings, subject_a, subject_b)
    subject_a_ratings = subjects_ratings[subject_a]
    subject_b_ratings = subjects_ratings[subject_b]
    objects = (subject_a_ratings.keys + subject_b_ratings.keys).uniq
    
    score = 0.0
    
    objects.each do |object|
      a_rating = subject_a_ratings[object]
      b_rating = subject_b_ratings[object]
      
      if a_rating and b_rating
        score += 1 - (a_rating - b_rating).abs
      end
    end
    
    score/objects.size
  end
  
  # Returns a distance-based similarity score for subject_a and subject_b
  # subjects_ratings is a hash with format {"subject_a" => {"object_a" => 1.0, "object_b" => 0.0...}, "subject_b" => {"object_a" => 0.0, "object_c" => 1.0}}
  # subject_a/b are keys of interest of the subjects_ratings hash
  def euclidean(subjects_ratings, subject_a, subject_b, norm=true)
    subject_a_ratings = subjects_ratings[subject_a]
    subject_b_ratings = subjects_ratings[subject_b]
    objects = (subject_a_ratings.keys + subject_b_ratings.keys).uniq
    
    sum_diff_sq = 0.0
    n_in_common = 0
    
    objects.each do |object|
      if subject_a_ratings[object] and subject_b_ratings[object]
        n_in_common += 1
        
        a_rating = subject_a_ratings[object].to_f || 0.0
        b_rating = subject_b_ratings[object].to_f || 0.0
        diff_sq = (a_rating - b_rating) ** 2
        sum_diff_sq += diff_sq
      end
    end
    
    if n_in_common == 0
      return 500.0
    else
      if norm
        n_common_possible = [subject_a_ratings.size, subject_b_ratings.size].max
        common_ratio = n_in_common.to_f/n_common_possible
        return 1 / (1 + sum_diff_sq) * common_ratio
      else
        return sum_diff_sq
      end
    end
    
  end
  
  # Returns pearson correlation coefficient for subject_a and b
  # subjects_ratings is a hash with format {"subject_a" => {"object_a" => 1.0, "object_b" => 0.0...}, "subject_b" => {"object_a" => 0.0, "object_c" => 1.0}}
  # subject_a/b are keys of interest of the subjects_ratings hash
  def pearson(subjects_ratings, subject_a, subject_b)
    subject_a_ratings = subjects_ratings[subject_a]
    subject_b_ratings = subjects_ratings[subject_b]
    objects = subject_a_ratings.keys & subject_b_ratings.keys

    n = objects.size
    return 0 if n==0
    
    sum_a = objects.inject(0.0){|sum, object| sum + subject_a_ratings[object]}
    sum_b = objects.inject(0.0){|sum, object| sum + subject_b_ratings[object]}
    
    sum_a_sq = objects.inject(0.0){|sum, object| sum + ( subject_a_ratings[object] ** 2 )}
    sum_b_sq = objects.inject(0.0){|sum, object| sum + ( subject_b_ratings[object] ** 2 )}
    
    sum_products = objects.inject(0.0){|sum, object| sum + ( subject_a_ratings[object] * subject_b_ratings[object] )}

    num = sum_products - (sum_a * sum_b / n)
    den = Math.sqrt( (sum_a_sq - (sum_a ** 2)/n) * (sum_b_sq - (sum_b ** 2)/n) )

    return 0 if den == 0
    
    r = num/den
    return r
  end
  
  # Returns list of subjects most similar to the given subject
  # Number of results is an optional param.
  def top_matches(subjects_ratings, subject, n=5)
  	scores = subjects_ratings.map do |critic, objects|
      if true # subject != critic
			  r = euclidean(subjects_ratings, subject, critic)
			  [r, critic]
		  end
  	end

  	matches = scores.compact.sort.reverse[0..n-1]
    return matches
  end
  
  # Returns list of objects unrated by the subject 
  # With ratings weighted for the subject
  def recommendations(subjects_ratings, subject)
    totals = {}
    similarity_sums = {}
    subject_objects = subjects_ratings[subject].keys
    
    subjects_ratings.keys.each do |critic|
      next if subject == critic
      similarity = pearson(subjects_ratings, subject, critic)
      next if similarity <= 0
      
      critic_objects = subjects_ratings[critic].keys
      critic_objects.each do |critic_object|
        unless subject_objects.include? critic_object
          totals[critic_object] ||= 0
          totals[critic_object] += subjects_ratings[critic][critic_object] * similarity

          similarity_sums[critic_object] ||= 0
          similarity_sums[critic_object] += similarity
        end
      end
      
    end

    rankings = []
    
    totals.each do |object, total|
      rankings << [(total/similarity_sums[object]), object]
    end

    recs = rankings.sort.reverse
    
    return recs
  end
  
end