package repository

import (
	"github.com/iqbaldwi09/bioskop/internal/domain"

	"github.com/jmoiron/sqlx"
)

type UserRepository interface {
	GetByEmail(email string) (*domain.User, error)
}

type userRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) UserRepository {
	return &userRepository{db}
}

func (r *userRepository) GetByEmail(email string) (*domain.User, error) {
	var user domain.User
	query := "SELECT * FROM users WHERE email = ? LIMIT 1"
	err := r.db.Get(&user, query, email)
	if err != nil {
		return nil, err
	}
	return &user, nil
}
