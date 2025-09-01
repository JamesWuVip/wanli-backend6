package com.wanli.service;

import com.wanli.entity.User;
import com.wanli.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

/**
 * 用户服务类.
 *
 * <p>提供用户相关的业务逻辑处理，包括用户创建、查询、更新、删除等操作。</p>.
 * <p>集成Spring Security进行密码加密和用户认证。</p>.
 *
 * @author JamesWu.
 * @since 1.0.0.
 */
@Service
@Transactional
public class UserService {

    /** 用户数据访问层，用于用户信息的数据库操作. */
    @Autowired
    private UserRepository userRepository;

    /** 密码编码器，用于密码的加密和验证. */
    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 创建新用户.
     *
     * <p>验证用户名和手机号的唯一性，设置默认值，加密密码。</p>.
     *
     * @param user 用户信息.
     * @return 创建的用户.
     * @throws RuntimeException 当用户名或手机号已存在时抛出.
     */
    public User createUser(final User user) {
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }

        // 检查手机号是否已存在
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("手机号已存在");
        }

        // 设置默认值
        user.setId(UUID.randomUUID().toString());
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        user.setStatus(User.UserStatus.ACTIVE);
        user.setEmailVerified(false);
        user.setPhoneVerified(false);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /**
     * 根据ID查询用户.
     *
     * @param id 用户ID.
     * @return 用户信息的Optional包装.
     */
    @Transactional(readOnly = true)
    public Optional<User> findById(final String id) {
        return userRepository.findById(id);
    }

    /**
     * 根据用户名查询用户.
     *
     * @param username 用户名.
     * @return 用户信息的Optional包装.
     */
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(final String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * 根据邮箱查询用户.
     *
     * @param email 邮箱地址.
     * @return 用户信息的Optional包装.
     */
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(final String email) {
        return userRepository.findByEmail(email);
    }

    /**
     * 根据手机号查询用户.
     *
     * @param phone 手机号.
     * @return 用户信息的Optional包装.
     */
    @Transactional(readOnly = true)
    public Optional<User> findByPhone(final String phone) {
        return userRepository.findByPhone(phone);
    }

    /**
     * 分页查询用户列表.
     *
     * @param pageable 分页参数.
     * @return 用户分页列表.
     */
    @Transactional(readOnly = true)
    public Page<User> findAll(final Pageable pageable) {
        return userRepository.findAll(pageable);
    }

    /**
     * 根据状态分页查询用户.
     *
     * @param status 用户状态.
     * @param pageable 分页参数.
     * @return 用户分页列表.
     */
    @Transactional(readOnly = true)
    public Page<User> findByStatus(final User.UserStatus status,
                                   final Pageable pageable) {
        return userRepository.findByStatus(status, pageable);
    }

    /**
     * 更新用户信息.
     *
     * <p>只更新允许修改的字段：全名、手机号、头像URL。</p>.
     *
     * @param id 用户ID.
     * @param user 更新的用户信息.
     * @return 更新后的用户信息.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public User updateUser(final String id, final User user) {
        Optional<User> existingUserOpt = userRepository.findById(id);
        if (!existingUserOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User existingUser = existingUserOpt.get();

        // 更新允许修改的字段
        if (user.getFullName() != null) {
            existingUser.setFullName(user.getFullName());
        }
        if (user.getPhone() != null) {
            existingUser.setPhone(user.getPhone());
        }
        if (user.getAvatarUrl() != null) {
            existingUser.setAvatarUrl(user.getAvatarUrl());
        }

        existingUser.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(existingUser);
    }

    /**
     * 更新用户密码.
     *
     * <p>验证旧密码后更新为新密码。</p>.
     *
     * @param id 用户ID.
     * @param oldPassword 旧密码（明文）.
     * @param newPassword 新密码（明文）.
     * @return 如果更新成功返回true，旧密码错误返回false.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public boolean updatePassword(final String id, final String oldPassword,
                                  final String newPassword) {
        Optional<User> userOpt = userRepository.findById(id);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User user = userOpt.get();

        // 验证旧密码
        if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
            return false;
        }

        // 更新密码
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());

        userRepository.save(user);
        return true;
    }

    /**
     * 更新用户状态.
     *
     * @param id 用户ID.
     * @param status 新状态.
     * @return 更新后的用户信息.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public User updateUserStatus(final String id,
                                 final User.UserStatus status) {
        Optional<User> userOpt = userRepository.findById(id);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User user = userOpt.get();
        user.setStatus(status);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /**
     * 验证邮箱.
     *
     * <p>将用户的邮箱验证状态设置为已验证。</p>.
     *
     * @param id 用户ID.
     * @return 更新后的用户信息.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public User verifyEmail(final String id) {
        Optional<User> userOpt = userRepository.findById(id);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User user = userOpt.get();
        user.setEmailVerified(true);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /**
     * 验证手机号.
     *
     * <p>将用户的手机号验证状态设置为已验证。</p>.
     *
     * @param id 用户ID.
     * @return 更新后的用户信息.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public User verifyPhone(final String id) {
        Optional<User> userOpt = userRepository.findById(id);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User user = userOpt.get();
        user.setPhoneVerified(true);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /**
     * 更新最后登录时间.
     *
     * <p>将用户的最后登录时间设置为当前时间。</p>.
     *
     * @param id 用户ID.
     */
    public void updateLastLoginTime(final String id) {
        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setLastLoginAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
        }
    }

    /**
     * 软删除用户.
     *
     * <p>将用户状态设置为DELETED，不进行物理删除。</p>.
     *
     * @param id 用户ID.
     * @throws RuntimeException 当用户不存在时抛出.
     */
    public void deleteUser(final String id) {
        Optional<User> userOpt = userRepository.findById(id);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("用户不存在");
        }

        User user = userOpt.get();
        user.setStatus(User.UserStatus.DELETED);
        user.setUpdatedAt(LocalDateTime.now());

        userRepository.save(user);
    }

    /**
     * 检查用户名是否存在.
     *
     * @param username 用户名.
     * @return 如果用户名存在返回true，否则返回false.
     */
    @Transactional(readOnly = true)
    public boolean existsByUsername(final String username) {
        return userRepository.existsByUsername(username);
    }

    /**
     * 检查邮箱是否存在.
     *
     * @param email 邮箱地址.
     * @return 如果邮箱存在返回true，否则返回false.
     */
    @Transactional(readOnly = true)
    public boolean existsByEmail(final String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * 检查手机号是否存在.
     *
     * @param phone 手机号.
     * @return 如果手机号存在返回true，否则返回false.
     */
    @Transactional(readOnly = true)
    public boolean existsByPhone(final String phone) {
        return userRepository.existsByPhone(phone);
    }

    /**
     * 统计用户总数.
     *
     * @return 用户总数.
     */
    @Transactional(readOnly = true)
    public long countUsers() {
        return userRepository.count();
    }

    /**
     * 根据状态统计用户数量.
     *
     * @param status 用户状态.
     * @return 指定状态的用户数量.
     */
    @Transactional(readOnly = true)
    public long countByStatus(final User.UserStatus status) {
        return userRepository.countByStatus(status);
    }
}