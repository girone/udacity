from sklearn import linear_model
import matplotlib.pyplot as plt

reg = linear_model.LinearRegression()
reg.fit(x, y)

reg.coef_
reg.intercept_
reg.score(x, y)

reg.predict(x_test)

### Visualization

plt.scatter(x, y)
plt.plot(x, reg.predict(x), color="blue", linewidth=3)
plt.xlabel("ages")
plt.ylabel("net worth")
plt.show()