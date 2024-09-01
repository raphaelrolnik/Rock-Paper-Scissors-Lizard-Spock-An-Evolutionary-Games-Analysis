to setup
  clear-all
  ask patches [
    ; Start populations at roughly even levels.
    set pcolor one-of [red green blue black]
  ]
  reset-ticks
end

to go
  ; Place your logic for the 'go' procedure here.
  ; For example, you could add behaviors for patches or turtles.
end


; This model uses an event-based approach. It calculates how many events
; of each type should occur each tick and then executes those events in a random order.
; Event type could be signified by any constant. Here, we use the numbers 0, 1, and 2 to signify
; event types, but then store those numbers in variables with clear names for readability.

to go
  let swap-event 0
  let reproduce-event 1
  let select-event 2

  ; Note that we have to compute the number of global events rather than the
  ; number of actions that each individual patch performs since the execution of those
  ; events has to be random between the patches. That is, a single patch can’t perform
  ; all of their actions in one go: suppose they end up executing 5 swaps in one tick.
  ; The swaps would be shuffling things around locally rather than allowing for an organism
  ; to travel multiple steps.

  ; Hence, this code creates a list with an entry for each event type that
  ; should occur this tick, then shuffles that list so that the events are in a random order.
  ; We then iterate through the list, and random neighboring patches run the corresponding event.
  
  let repetitions count patches / 3 ; At default settings, there will be an average of 1 event per patch.
  let events shuffle ( sentence
    n-values random-poisson (repetitions * swap-rate) [swap-event]
    n-values random-poisson (repetitions * reproduce-rate) [reproduce-event]
    n-values random-poisson (repetitions * select-rate) [select-event]
  )

  foreach events [ event ->
    ask one-of patches [
      let target one-of neighbors4
      if event = swap-event [ swap target ]
      if event = reproduce-event [ reproduce target ]
      if event = select-event [ select target ]
    ]
  ]
  tick
end

; Patch procedures

; Swap PCOLOR with TARGET.
to swap [target]
  let old-color pcolor
  set pcolor [pcolor] of target
  ask target [ set pcolor old-color ]
end

; Compete with TARGET. The loser becomes blank.
to select [target]
  ifelse beat? target [
    ask target [ set pcolor black ]
  ] [
    if [ beat? myself ] of target [
      set pcolor black
    ]
  ]
end


; Procedure to select a target and apply actions based on the result of a competition
to select [target]
  ifelse beat? target [
    ask target [ set pcolor black ]
  ] [
    if [ beat? myself ] of target [
      set pcolor black
    ]
  ]
end

; If TARGET is blank, reproduce on that patch. If I'm blank, TARGET reproduces on my patch.
to reproduce [target]
  ifelse [pcolor] of target = black [
    ask target [ set pcolor [pcolor] of myself ]
  ] [
    if pcolor = black [
      set pcolor [pcolor] of target
    ]
  ]
end

; Determine whether or not I beat TARGET
to-report beat? [target]
  report (pcolor = red and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = blue) or
         (pcolor = blue and [pcolor] of target = red)
end

; Utility procedures
to-report rate-from-exponent [exponent]
  report 10 ^ exponent
end

to-report swap-rate
  report rate-from-exponent swap-rate-exponent
end

to-report reproduce-rate
  report rate-from-exponent reproduce-rate-exponent
end

to-report select-rate
  report rate-from-exponent select-rate-exponent
end

; Convert the given rate to a percentage of how much that action happens
to-report percentage [rate]
  report 100 * rate / (swap-rate + reproduce-rate + select-rate)
end



to-report beat? [target]
  report (pcolor = red and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = blue) or
         (pcolor = blue and [pcolor] of target = red) or
         (pcolor = red and [pcolor] of target = orange) or
         (pcolor = yellow and [pcolor] of target = red) or
         (pcolor = orange and [pcolor] of target = yellow) or
         (pcolor = yellow and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = orange) or
         (pcolor = orange and [pcolor] of target = blue) or
         (pcolor = blue and [pcolor] of target = yellow)
end


to-report beat? [target]
  report (pcolor = red and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = blue) or
         (pcolor = blue and [pcolor] of target = red) or
         (pcolor = red and [pcolor] of target = red) ; or
         ;(pcolor = blue and [pcolor] of target = blue) or
         ;(pcolor = green and [pcolor] of target = green)
end
