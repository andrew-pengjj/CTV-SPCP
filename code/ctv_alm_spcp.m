%% solve the problem 
%              min_X ||D_x(X)||_*+||D_y(X)||_* +||D_z(X)||_* +\lambda||E||_1
%                                   s.t.  Y= X+E
%                          ===============================
%              min_X ||X1||_*+||X2||_* +||X3||_* +\lambda||E||_1
%                            s.t.  Y= X+E
%                                  D_x(X)=X1 
%                                  D_y(X)=X2 
%                                  D_z(X)=X3 
%                          ===============================                       
%         D is difference operator,T is difference tensor,T is known
%  ------------------------------------------------------------------------


function [ output_image,E] =ctv_alm_spcp(oriData3_noise,sigma,weight)
tol     = 1e-6;
maxIter = 400;
rho     = 1.25;
% max_mu  = 1e6;
% mu      = 1e-3;
[M,N,p] = size(oriData3_noise);
eps = 1e-6;
if nargin < 2
    sigma = 0;
end
if nargin < 3
    weight = 1;
end
lambda  = 3/sqrt(M*N);
beta    = 3*sqrt(2)/((sqrt(M*N)+sqrt(p))*sigma+eps);
sizeD   = size(oriData3_noise);
D       = zeros(M*N,p) ;
for i=1:p
    bandp = oriData3_noise(:,:,i);
    D(:,i)= bandp(:);
end
normD   = norm(D,'fro');
% initialize
norm_two = lansvd(D, 1, 'L');
norm_inf = norm( D(:), inf) / lambda;
dual_norm = max(norm_two, norm_inf);

mu = 1.25/dual_norm;%1.25/norm_two % this one can be tuned
max_mu = mu * 1e7;
%% FFT setting
h               = sizeD(1);
w               = sizeD(2);
d               = sizeD(3);
%% 
Eny_x   = ( abs(psf2otf([+1; -1], [h,w,d])) ).^2  ;
Eny_y   = ( abs(psf2otf([+1, -1], [h,w,d])) ).^2  ;
Eny_z   = ( abs(psf2otf([+1, -1], [w,d,h])) ).^2  ;
Eny_z   =  permute(Eny_z, [3, 1 2]);
determ  =  Eny_x + Eny_y + Eny_z;
%% Initializing optimization variables
X              = randn(M*N,p);
E              = zeros(M*N,p);
G              = zeros(M*N,p);

M1 = D / dual_norm;
M2 = zeros(size(D));  % multiplier for Dx_X-X1
M3 = zeros(size(D));  % multiplier for Dy_X-X2
M4 = zeros(size(D));  % multiplier for Dz_X-X3

% main loop
iter = 0;
tic
while iter<maxIter
    iter          = iter + 1;   
    %% -Updata X1,X2,X3
    [u,s,v] = svd(reshape(diff_x(X,sizeD),[M*N,p])+M2/mu,'econ');
    X1      = u*softthre(s,1/mu)*v';
    [u,s,v] = svd(reshape(diff_y(X,sizeD),[M*N,p])+M3/mu,'econ');
    X2      = u*softthre(s,1/mu)*v';
    [u,s,v] = svd(reshape(diff_z(X,sizeD),[M*N,p])+M4/mu,'econ');
    X3      = u*softthre(s,weight/mu)*v';
    %% -Updata X
    diffT_p  = diff_xT(mu*X1-M2,sizeD)+diff_yT(mu*X2-M3,sizeD);
    diffT_p  = diffT_p + diff_zT(mu*X3-M4,sizeD);
    numer1   = reshape( diffT_p + mu*(D(:)-E(:)-G(:)) + M1(:), sizeD);
    x        = real( ifftn( fftn(numer1) ./ (mu*determ + mu) ) );
    X        = reshape(x,[M*N,p]);
    %% -Update E
    E             = softthre(D-X-G+M1/mu, lambda/mu);
    %% -Update G
    G = (M1+mu*(D-X-E))/(beta+mu);% Gaussian noise
    
    %% stop criterion  
    leq1 = D -X -E - G;
    leq2 = reshape(diff_x(X,sizeD),[M*N,p])- X1;
    leq3 = reshape(diff_y(X,sizeD),[M*N,p])- X2;
    leq4 = reshape(diff_z(X,sizeD),[M*N,p])- X3;
    stopC1 = norm(leq1,'fro')/normD;
    stopC2 = max(abs(leq2(:)));
    stopC4 = norm(leq4,'fro')/normD;
%     disp(['iter ' num2str(iter) ',mu=' num2str(mu,'%2.1e')  ...
%             ',Y-X-E=' num2str(stopC1,'%2.3e') ',||DX-X1||=' num2str(stopC2,'%2.3e')...
%             ',|DZ-X3|' num2str(stopC4,'%2.3e')]);
    if stopC1<tol && stopC2<tol
        break;
    else
        M1 = M1 + mu*leq1;
        M2 = M2 + mu*leq2;
        M3 = M3 + mu*leq3;
        M4 = M4 + mu*leq4;
        mu = min(max_mu,mu*rho); 
    end 
%     load('Simu_indian.mat');
%     [mp(iter),sm(iter),er(iter)]=msqia(simu_indian,reshape(X,[M,N,p]));
end
% [u,s,v]= svd(D-E,'econ');
% diags = diag(s);
% for svp = 1:length(diags)
%     if sum(diags(1:svp))/sum(diags)>=0.995
%         break;
%     end
% end
% X = u(:,1:svp)*diag(diags(1:svp))*v(:,1:svp)';
output_image = reshape(X,[M,N,p]);
end