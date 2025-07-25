/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H
#define VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H

#include "veutil/qt/ve_qitem.hpp"

#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>

namespace Victron {

namespace VenusOS {

class VeQItemMockProducer;

class VeQItemMock : public VeQItem
{
	Q_OBJECT

public:
	VeQItemMock(VeQItemMockProducer *producer);

	int setValue(QVariant const &value) override;

private:
	VeQItemMockProducer *m_producer = nullptr;
};

class VeQItemMockProducer : public VeQItemProducer
{
	Q_OBJECT

public:
	VeQItemMockProducer(VeQItem *root, const QString &id, QObject *parent = nullptr);

	void setValue(const QString &uid, const QVariant &value);
	QVariant value(const QString &uid) const;
	void removeValue(const QString &uid);
	void removeServices(const QString &serviceType);

	VeQItem *createItem() override;

	static QObject* instance(QQmlEngine *engine, QJSEngine *);

Q_SIGNALS:
	void dbusUidChanged();
	void mqttUidChanged();

private:
	static QString normalizedUid(const QString &uid);
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H

