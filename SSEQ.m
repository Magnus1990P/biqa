function score = SSEQ( imdist )

    feature=feature_extraction(imdist, 3);
    score=SSQA_by_f(feature);
    
end
