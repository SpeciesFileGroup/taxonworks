module Utilities::Arrays

  # 
  # LLM: # This code was generated at https://lmarena.ai/?arena
  # on Mar 22, 2025 and modified.
  #

  # 
  # Example Usage:
  # arr1 = ["apple", "banana", "cherry", "date"]
  # arr2 = ["banana", "grape", "date", "fig"]

  # aligned1, aligned2 = align_arrays(arr1, arr2)
  # 
  def self.align(arr1, arr2)
    # Step 1: Initialize the DP table
    m = arr1.length
    n = arr2.length
    dp = Array.new(m + 1) { Array.new(n + 1, 0) }

    # Step 2: Fill the DP table (Longest Common Subsequence logic)
    (1..m).each do |i|
      (1..n).each do |j|
        if arr1[i - 1] == arr2[j - 1]
          dp[i][j] = dp[i - 1][j - 1] + 1
        else
          dp[i][j] = [dp[i - 1][j], dp[i][j - 1]].max
        end
      end
    end

    # Step 3: Traceback to construct the aligned arrays
    aligned1 = []
    aligned2 = []
    i, j = m, n

    while i > 0 && j > 0
      if arr1[i - 1] == arr2[j - 1]
        # Matching element found, add it to both aligned arrays
        aligned1.unshift(arr1[i - 1])
        aligned2.unshift(arr2[j - 1])
        i -= 1
        j -= 1
      elsif dp[i - 1][j] >= dp[i][j - 1]
        # Gap in arr2
        aligned1.unshift(arr1[i - 1])
        aligned2.unshift(nil)
        i -= 1
      else
        # Gap in arr1
        aligned1.unshift(nil)
        aligned2.unshift(arr2[j - 1])
        j -= 1
      end
    end

    # Add remaining elements from arr1 (if any)
    while i > 0
      aligned1.unshift(arr1[i - 1])
      aligned2.unshift(nil)
      i -= 1
    end

    # Add remaining elements from arr2 (if any)
    while j > 0
      aligned1.unshift(nil)
      aligned2.unshift(arr2[j - 1])
      j -= 1
    end

    # Return the aligned arrays
    [aligned1, aligned2]
  end

end
