close all
clear all
clc
ff=dir;
cc=0;
for ii=1: length(ff)
    ch=ff(ii).name;
    if ch(1)=='s'
        cc=cc+1;
        names(cc)=string(ff(ii).name);
    end
end
xPos=[];
lab=[];
for ii=1:cc
    ch=char(names(ii));
    gg=find(ch=='_');
    lmd(ii)=str2num(string(replace(ch(gg(1)+1:gg(3)-1),'_','.')));
    curr(ii)=str2num(string(replace(ch(gg(3)+1:gg(4)-1),'_','.')));
    ept(ii)=str2num(string(replace(ch(gg(5)+1:gg(7)-1),'_','.')));
    pres(ii)=str2num(string(replace(ch(gg(8)+1:gg(9)-1),'_','.')));

    fig=openfig(names(ii));
    lineObjs = findobj(fig, 'Type', 'Line');

    validIdx = false(size(lineObjs));
    for k = 1:length(lineObjs)
        if ~isempty(lineObjs(k).XData) && ~isempty(lineObjs(k).YData)
            validIdx(k) = true;
        end
    end
 lineObjs = lineObjs(validIdx);
 xx(:,ii)=lineObjs.XData;
 yy(:,ii)=lineObjs.YData;

 constObjs = findobj(fig, 'Type', 'ConstantLine');

  for jj = 1:length(constObjs)
        xPos = [xPos; constObjs(jj).Value];
        lab  = [lab; string(constObjs(jj).Label)];
  end


end
pressure=unique(pres);
wl=unique(lmd);
current=unique(curr);
exp_t=unique(ept);

[xPos,idx]=unique(xPos);
lab=lab(idx);

save('identified_data.mat','xx','yy','lab',"xPos","exp_t","current","wl","pressure",'pres','curr','ept','lmd');