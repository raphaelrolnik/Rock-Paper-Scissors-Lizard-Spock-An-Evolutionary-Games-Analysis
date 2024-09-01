globals [
  blue-patch-count
]

to setup
  clear-all
  ask patches [
    ; Start populations at roughly even levels.
    set blue-patch-count 0
    set pcolor one-of [red green blue orange yellow black]
    if pcolor = blue [ ; Check if the patch is blue
      set blue-patch-count blue-patch-count + 1 ; Increment the count if the patch is blue
    ]
  ]
  reset-ticks
end

to go
  ; This model uses an event-based approach. It calculates how many events
  ; of each type should occur each tick and then executes those events in a random order.
  ; Event type could be signified by any constant. Here, we use the numbers 0, 1, and 2
  ; to signify event type, but then store those numbers in variables with clear names for readability.
  let swap-event 0
  let reproduce-event 1
  let select-event 2

  set blue-patch-count count patches with [pcolor = blue]

  ; Note that we have to compute the number of global events rather than the
  ; number of actions that each individual patch performs since the execution of those
  ; events has to be random between the patches. That is, a single patch can’t perform
  ; all of its actions in one go: suppose they end up executing 5 swaps in one tick.
  ; The swaps would be shuffling things around locally rather than allowing for an organism
  ; to travel multiple steps.
  ; Hence, this code creates a list with an entry for each event type that should occur
  ; this tick, then shuffles that list so that the events are in a random order.
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

; Raph Trying to add color swapping
;
; Determine whether or not I beat TARGET
to-report beat? [target]
  if blue-patch-count < 1500 [ ; CASE IF BLUE POPULATION IS DYING
    ; Add your logic here for the beat condition
  ]
end

report (pcolor = red and [pcolor] of target = green) or
       (pcolor = green and [pcolor] of target = blue) or
       (pcolor = blue and [pcolor] of target = red) or
       (pcolor = red and [pcolor] of target = orange) or
       (pcolor = yellow and [pcolor] of target = red) or
       (pcolor = orange and [pcolor] of target = yellow) or
       (pcolor = yellow and [pcolor] of target = green) or
       (pcolor = green and [pcolor] of target = orange) or
       (pcolor = orange and [pcolor] of target = blue) or
       (pcolor = blue and [pcolor] of target = yellow) or
       (pcolor = blue and [pcolor] of target = blue)

ifelse blue-patch-count >= 1500 [ ; CASE IF BLUE IS HEALTHY POPULATION
  let random-number random-float 1
  ifelse random-number < 0.5 [
    ; Code to be executed when the condition is true
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
  ] [
    ; Code to be executed when the condition is false
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
  ]
]

; Handle the case where ticks < 150 but there’s no else block, you can
; add specific behavior here if needed
end

; Patch procedures

; Swap PCOLOR with TARGET.
to swap [ target ]
  let old-color pcolor
  set pcolor [pcolor] of target
  ask target [ set pcolor old-color ]
end

; Compete with TARGET. The loser becomes black.
to select [ target ]
  ifelse beat? target [
    ask target [ set pcolor black ]
  ] [
    if [ beat? myself ] of target [
      set pcolor black
    ]
  ]
end

; If TARGET is black, reproduce on that patch. If I’m black, TARGET reproduces on my patch.
to reproduce [ target ]
  ifelse [pcolor] of target = black [
    ask target [
      set pcolor [pcolor] of myself
    ]
  ] [
    if pcolor = black [
      set pcolor [pcolor] of target
    ]
  ]
end

; Determine whether or not I beat TARGET
to-report beat? [ target ]
  ; Add your logic here for determining if the current patch beats the target patch
  ; For example, this could be a rule based on colors as shown earlier
  report (pcolor = red and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = blue) or
         (pcolor = blue and [pcolor] of target = red) or
         ; Add additional conditions as necessary
         false ; Return false by default if no conditions are met
end


; Determine if the current patch wins against the target based on colors
to-report beat? [ target ]
  report (pcolor = red and [pcolor] of target = green) or
         (pcolor = green and [pcolor] of target = blue) or
         (pcolor = red and [pcolor] of target = red)
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

; Counting patches population
to-report count-patches-with-color [col]
  report count patches with [pcolor = col]
end





