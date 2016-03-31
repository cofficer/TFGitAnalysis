function [ data ] = removeNans( data )
%removes all the trials that contain NaN values

vNan=ones(1,length(data.trial));

for naTrial = 1:length(data.trial)

    if sum(sum(isnan(data.trial{naTrial})))>0
        vNan(naTrial)=0;
    end
end

cfg=[];
cfg.trials=logical(vNan');
data=ft_redefinetrial(cfg,data);


end

