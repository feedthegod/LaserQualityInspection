% 生成激光光斑
beam_size = 256; % 光斑尺寸
beam_std = 20; % 光斑标准差
beam_intensity = 100; % 光斑强度
laser_beam = beam_intensity * exp(-((1:beam_size) - (beam_size + 1) / 2).^2 / (2 * beam_std^2));

% 剖面扫描方向和位置
scan_direction = 'horizontal'; % 可选值：'horizontal'、'vertical'、'diagonal'
scan_position = ceil(beam_size / 2); % 扫描线位置，修正为从1开始
if scan_position > size(laser_beam, 1)
    scan_position = size(laser_beam, 1);
end


% 断言：确保 scan_position 的值在合理范围内
assert(scan_position >= 1 && scan_position <= size(laser_beam, 1), 'scan_position 超出合理范围');

% 根据剖面扫描方向获取剖面数据
switch scan_direction
    case 'horizontal'
        profile = laser_beam(scan_position, :); % 修正索引
    case 'vertical'
        profile = laser_beam(:, scan_position);
    case 'diagonal'
        profile = diag(laser_beam);
    otherwise
        error('无效的剖面扫描方向');
end

% 计算剖面数据的峰值、FWHM和光斑质量参数
[max_value, max_index] = max(profile);
half_max_value = max_value / 2;
left_index = find(profile(1:max_index) <= half_max_value, 1, 'last');
right_index = max_index + find(profile(max_index:end) <= half_max_value, 1, 'first') - 1;
fwhm = right_index - left_index + 1;
m2 = sum(((1:numel(profile)) - max_index).^2 .* profile') / max_value;
normalized_m2 = m2 / fwhm^2;

% 显示生成的激光光斑和剖面扫描结果
figure;
subplot(2, 1, 1);
plot(laser_beam);
xlabel('位置');
ylabel('强度');
title('生成的激光光斑');
subplot(2, 1, 2);
plot(profile);
hold on;
plot([left_index, right_index], [half_max_value, half_max_value], 'r', 'LineWidth', 2);
xlabel('位置');
ylabel('强度');
title('剖面扫描结果');
legend('剖面数据', 'FWHM');
fprintf('峰值：%.2f\nFWHM：%.2f\n光斑质量参数：%.2f\n', max_value, fwhm, normalized_m2);
